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
  public init(id: Int, name: String, firstKind: FirstKind) {
    self.id = id
    self.name = name
    self.firstKind = firstKind
  }
  public let id: Int
  public let name: String
  public let firstKind: FirstKind
  
  @CasePathable @Selection
  public enum FirstKind: Sendable, Equatable {
    case decimalValue(Decimal)
    case decimalAndUnit(First.DecimalAndUnit)
  }
  
  @Selection
  public struct DecimalAndUnit: Sendable, Equatable {
    public init(decimalPart: Decimal, unit: String) {
      self.decimalPart = decimalPart
      self.unit = unit
    }
    public let decimalPart: Decimal
    public let unit: String
  }
}

@Table
public struct Second: Identifiable, Sendable, Equatable {
  public init(id: Int, name: String?, booleanField: Bool, firstId: Int, sizeField: Decimal) {
    self.id = id
    self.name = name
    self.booleanField = booleanField
    self.firstId = firstId
    self.sizeField = sizeField
  }
  public let id: Int
  public let name: String?
  public let booleanField: Bool
  public let firstId: Int
  public let sizeField: Decimal
}

@Table
public struct Third: Identifiable, Sendable, Equatable {
  public init(
    id: Int,
    modifiedAt: Date,
    createdAt: Date
  ) {
    self.id = id
    self.modifiedAt = modifiedAt
    self.createdAt = createdAt
  }
  public let id: Int
  public var modifiedAt: Date
  public var createdAt: Date
}

@Table
public struct SecondThirdMapping: Identifiable, Sendable, Equatable {
  public init(id: Int, thirdId: Int, secondId: Int, quantity: Decimal) {
    self.id = id
    self.thirdId = thirdId
    self.secondId = secondId
    self.quantity = quantity
  }
  public let id: Int
  public let thirdId: Int
  public let secondId: Int
  public let quantity: Decimal
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
      table.column("decimalValue", .text)
      table.column("decimalPart", .text)
      table.column("unit", .text)
    }
  }
  
  migrator.registerMigration("Add Second table") { db in
    try db.create(table: Second.tableName) { table in
      table.autoIncrementedPrimaryKey(Second.columns.id.name)
      table.column(Second.columns.name.name, .text)
      table.column(Second.columns.booleanField.name, .boolean).notNull()
      table.column(Second.columns.firstId.name, .integer).notNull()
      table.column(Second.columns.sizeField.name, .text).notNull()
    }
  }
  
  migrator.registerMigration("Add Third table") { db in
    try db.create(table: Third.tableName) { table in
      table.autoIncrementedPrimaryKey(Third.columns.id.name)
      table.column(Third.columns.modifiedAt.name, .datetime).notNull()
      table.column(Third.columns.createdAt.name, .datetime).notNull()
    }
  }
  
  migrator.registerMigration("Add Mapping table") { db in
    try db.create(table: SecondThirdMapping.tableName) { table in
      table.autoIncrementedPrimaryKey(SecondThirdMapping.columns.id.name)
      table.column(SecondThirdMapping.columns.thirdId.name, .integer).notNull()
      table.column(SecondThirdMapping.columns.secondId.name, .integer).notNull()
      table.column(SecondThirdMapping.columns.quantity.name, .text).notNull()
    }
  }

  try migrator.migrate(database)

  return database
}
