import Foundation
import Testing
@testable import DbLibrary

@Test func passingExample() async throws {
  let database = try! appDatabase()
  
  try await database.write { db in
    let decimalAndUnit = First.DecimalAndUnit(decimalPart: 1, unit: "m")
    let firstKind = First.FirstKind.decimalAndUnit(decimalAndUnit)
    let first = try First.insert {
      First.Draft(
        name: "first",
        firstKind: firstKind
      )
    }
    .returning(\.self)
    .fetchOne(db)!
    
    let second = try Second.insert {
      Second.Draft(
        name: "second",
        booleanField: false,
        firstId: first.id,
        sizeField: 1
      )
    }
    .returning(\.self)
    .fetchOne(db)!
    
    let third = try Third.insert {
      Third.Draft(
        modifiedAt: Date(),
        createdAt: Date()
      )
    }
    .returning(\.self)
    .fetchOne(db)!
    
    let mapping = try SecondThirdMapping.insert {
      SecondThirdMapping.Draft(
        thirdId: third.id,
        secondId: second.id,
        quantity: 1
      )
    }
    .returning(\.self)
    .fetchOne(db)!

    print("First: \(first)")
    print("Second: \(second)")
    print("Third: \(third)")
    print("Mapping: \(mapping)")
    
    let flattendRecords = try FlattendRecords.all().fetchAll(db)
    print("flattendRecords: \(flattendRecords)")
  }
}

@Test func failingExample() async throws {
  let database = try! appDatabase()
  
  try await database.write { db in
    let firstKind = First.FirstKind.decimalValue(1)
    let first = try First.insert {
      First.Draft(
        name: "first",
        firstKind: firstKind
      )
    }
    .returning(\.self)
    .fetchOne(db)!
    
    let second = try Second.insert {
      Second.Draft(
        name: "second",
        booleanField: false,
        firstId: first.id,
        sizeField: 1
      )
    }
    .returning(\.self)
    .fetchOne(db)!
    
    let third = try Third.insert {
      Third.Draft(
        modifiedAt: Date(),
        createdAt: Date()
      )
    }
    .returning(\.self)
    .fetchOne(db)!
    
    let mapping = try SecondThirdMapping.insert {
      SecondThirdMapping.Draft(
        thirdId: third.id,
        secondId: second.id,
        quantity: 1
      )
    }
    .returning(\.self)
    .fetchOne(db)!

    print("First: \(first)")
    print("Second: \(second)")
    print("Third: \(third)")
    print("Mapping: \(mapping)")
    
    let flattendRecords = try FlattendRecords.all().fetchAll(db)
    print("flattendRecords: \(flattendRecords)")
  }
}
