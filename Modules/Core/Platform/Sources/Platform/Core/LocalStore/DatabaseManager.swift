import Foundation
import SwiftData

// MARK: - DatabaseManager

protocol DatabaseManager {
  func fetch<Model: PersistentModel>(
    type: Model.Type,
    sortBy: KeyPath<Model, some Comparable>,
    ascending: Bool
  ) async -> Result<[Model], Error>

  func save<Model: PersistentModel>(model: Model) async -> Result<Model, Error>

  func delete<Model: PersistentModel & Identifiable>(
    type: Model.Type,
    id: Model.ID
  ) async -> Result<Bool, Error>

  func deleteAll(type: (some PersistentModel).Type) async -> Result<Bool, Error>
}

// MARK: - DatabaseManagerPlatform

/// struct DatabaseManagerPlatform: DatabaseManager {.
struct DatabaseManagerPlatform {

  init(schema: Schema, modelConfiguration: ModelConfiguration) {
    do {
      modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
//      print("[DatabaseManagerPlatform][ERROR] \(error)")
      fatalError("Could not create ModelContainer: \(error)")
    }
  }

  private let modelContainer: ModelContainer

}
