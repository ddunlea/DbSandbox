import CasePaths
import Dependencies
import Foundation
import GRDB
import OSLog
import StructuredQueries

extension Decimal: @retroactive LosslessStringConvertible, @retroactive QueryBindable {
  public init?(_ description: String) {
    self.init(string: description)
  }
  
  public var description: String {
    return NSDecimalNumber(decimal: self).stringValue
  }
}

@Table
public struct First: Identifiable, Sendable, Equatable {
  public init(id: Int, name: String, description: String) {
    self.id = id
    self.name = name
    self.description = description
  }
  public let id: Int
  public let name: String
  public let description: String
}

@Table
public struct Second: Identifiable, Sendable, Equatable {
  public init(id: Int, name: String, count: Int) {
    self.id = id
    self.name = name
    self.count = count
  }
  public let id: Int
  public let name: String
  public let count: Int
}


private let logger = Logger(subsystem: "Database", category: "Database")

public func appDatabase() throws -> any DatabaseWriter {
  @Dependency(\.context) var context
  let database: any DatabaseWriter
  var configuration = Configuration()
  configuration.foreignKeysEnabled = true
  configuration.prepareDatabase { db in
    #if DEBUG
      db.trace(options: .profile) {
        if context == .preview {
          print("\($0.expandedDescription)")
        } else {
          logger.debug("\($0.expandedDescription)")
        }
      }
    #endif
  }
  if context == .preview {
    database = try DatabaseQueue(configuration: configuration)
  } else {
    let path =
    context == .live
    ? URL.documentsDirectory.appending(component: "db.sqlite").path()
    : URL.temporaryDirectory.appending(component: "\(UUID().uuidString)-db.sqlite").path()
    logger.info("open \(path)")
    database = try DatabasePool(path: path, configuration: configuration)
  }
  var migrator = DatabaseMigrator()
  #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
  #endif
  
  
  migrator.registerMigration("Add First table") { db in
    try db.create(table: First.tableName) { table in
      table.autoIncrementedPrimaryKey(First.columns.id.name)
      table.column(First.columns.name.name, .text).notNull()
      table.column(First.columns.description.name, .text).notNull()
    }
  }
  
  migrator.registerMigration("Add Second table") { db in
    try db.create(table: Second.tableName) { table in
      table.autoIncrementedPrimaryKey(Second.columns.id.name)
      table.column(Second.columns.name.name, .text)
      table.column(Second.columns.count.name, .boolean).notNull()
    }
  }

  try migrator.migrate(database)

  return database
}
