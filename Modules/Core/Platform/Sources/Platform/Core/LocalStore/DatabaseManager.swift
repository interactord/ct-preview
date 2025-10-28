import Foundation
@preconcurrency import SwiftData

// MARK: - DatabaseManager

/// A lightweight abstraction over SwiftData operations.
/// All methods run on the main actor because `ModelContainer.mainContext` is main-actor isolated.
@MainActor
protocol DatabaseManager {
  func fetchList<Model: PersistentModel>(sort: KeyPath<Model, some Comparable> & Sendable, ascending: Bool) throws -> [Model]
  func fetch<Model: PersistentModel & IdentifiableModel>(id: String) throws -> Model?
  func save<Model: PersistentModel>(model: Model) throws -> Model
  func delete<Model: PersistentModel & IdentifiableModel>(type: Model.Type, id: String) throws -> Model?
  func deleteAll(type: (some PersistentModel).Type) throws -> Bool
}

// MARK: - DatabaseManagerPlatform

/// Concrete SwiftData-backed implementation.
@MainActor
struct DatabaseManagerPlatform {

  init(schema: Schema, modelConfiguration: ModelConfiguration) {
    do {
      modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }

  private let modelContainer: ModelContainer
}

// MARK: DatabaseManager

extension DatabaseManagerPlatform: DatabaseManager {

  func fetchList<Model: PersistentModel>(sort: KeyPath<Model, some Comparable> & Sendable, ascending: Bool) throws -> [Model] {
    let sortDescriptor = SortDescriptor(sort, order: ascending ? .forward : .reverse)
    let fetchDescriptor = FetchDescriptor<Model>(sortBy: [sortDescriptor])

    do {
      return try modelContainer.mainContext.fetch(fetchDescriptor)
    }
  }

  func fetch<Model: PersistentModel & IdentifiableModel>(id: String) throws -> Model? {
    let fetchDescriptor = FetchDescriptor<Model>(
      predicate: #Predicate { $0.id == id }
    )
    return try modelContainer.mainContext.fetch(fetchDescriptor).first
  }

  func save<Model: PersistentModel>(model: Model) throws -> Model {
    let context = modelContainer.mainContext
    context.insert(model)
    try context.save()
    return model
  }

  func delete<Model: PersistentModel & IdentifiableModel>(type: Model.Type, id: String) throws -> Model? {
    let context = modelContainer.mainContext
    // Use a typed fetch to avoid generic ambiguity with `context.model(for:)`.
    let descriptor = FetchDescriptor<Model>(
      predicate: #Predicate { $0.id == id }
    )
    guard let object = try context.fetch(descriptor).first else { return .none }
    context.delete(object)
    try context.save()
    return object
  }

  func deleteAll<Model: PersistentModel>(type _: Model.Type) throws -> Bool {
    let context = modelContainer.mainContext
    // Fetch all instances of Model and delete them individually.
    let descriptor = FetchDescriptor<Model>()
    let all = try context.fetch(descriptor)
    for object in all {
      context.delete(object)
    }
    try context.save()
    return true
  }
}
