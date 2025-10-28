import Speech

@available(iOS 26.0, *)
extension SpeechTranscriber.Preset {
  static var `default`: SpeechTranscriber.Preset {
    .init(
      transcriptionOptions: [
        .etiquetteReplacements
      ],
      reportingOptions: [
        .fastResults,
        .volatileResults
      ],
      attributeOptions: [
        .audioTimeRange
      ]
    )
  }
}
