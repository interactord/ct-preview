import Foundation
import Domain
@preconcurrency import AVFoundation

final class BufferConverter: @unchecked Sendable {
  private var converter: AVAudioConverter?
  private let lock = NSLock()
  
  func convertBuffer(_ buffer: AVAudioPCMBuffer, to format: AVAudioFormat) throws -> AVAudioPCMBuffer {
    // 같은 포맷이면 바로 반환
    guard buffer.format != format else { return buffer }
    
    // 컨버터 준비
    let converter = try prepareConverter(from: buffer.format, to: format)
    
    // 출력 버퍼 생성
    let outputBuffer = try createOutputBuffer(from: buffer, to: format)
    
    // 변환 실행
    try performConversion(from: buffer, to: outputBuffer, using: converter)
    
    return outputBuffer
  }
}

// MARK: - Private Methods
private extension BufferConverter {
  
  private func prepareConverter(from inputFormat: AVAudioFormat, to outputFormat: AVAudioFormat) throws -> AVAudioConverter {
    lock.lock()
    defer { lock.unlock() }
    
    if converter?.outputFormat != outputFormat {
      converter = AVAudioConverter(from: inputFormat, to: outputFormat)
    }
    
    guard let converter else {
      throw BufferConverterError.failedToCreateConverter
    }
    
    return converter
  }
  
  private func createOutputBuffer(from inputBuffer: AVAudioPCMBuffer, to format: AVAudioFormat) throws -> AVAudioPCMBuffer {
    let frameCapacity = AVAudioFrameCount(
      Double(inputBuffer.frameLength) * format.sampleRate / inputBuffer.format.sampleRate
    )
    
    guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else {
      throw BufferConverterError.failedToCreateBuffer
    }
    
    return outputBuffer
  }
  
  private func performConversion(from inputBuffer: AVAudioPCMBuffer, to outputBuffer: AVAudioPCMBuffer, using converter: AVAudioConverter) throws {
    var error: NSError?
    
    converter.convert(to: outputBuffer, error: &error) { _, status in
      status.pointee = .haveData
      return inputBuffer
    }
    
    if let error { throw error }
  }
}

// MARK: - Error Types
enum BufferConverterError: Error, LocalizedError {
  case failedToCreateConverter
  case failedToCreateBuffer
  
  var errorDescription: String? {
    switch self {
    case .failedToCreateConverter:
      return "Failed to create audio converter"
    case .failedToCreateBuffer:
      return "Failed to create conversion buffer"
    }
  }
}

