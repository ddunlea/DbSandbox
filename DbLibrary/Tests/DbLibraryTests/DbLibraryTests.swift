import Foundation
import Testing
@testable import DbLibrary

@Test func example() async throws {
  let database = try! appDatabase()
  
  try await database.write { db in
    let first = try First.insert {
      First.Draft(
        name: "first",
        description: "description"
      )
    }
    .returning(\.self)
    .fetchOne(db)!
    
    let second = try Second.insert {
      Second.Draft(
        name: "second",
        count: 2
      )
    }
    .returning(\.self)
    .fetchOne(db)!
    

    print("First: \(first)")
    print("Second: \(second)")
    
    let firstOrSecond = try FirstOrSecond.all().fetchAll(db)
    print("firstOrSecond: \(firstOrSecond.count)")
    firstOrSecond.forEach{ fos in
      print(fos)
      if fos.name == "first" {
        #expect(fos.first != nil)
      }
      if fos.name == "second" {
        #expect(fos.second != nil)
      }
    }
  }
}
