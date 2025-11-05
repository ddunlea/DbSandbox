import Foundation
import StructuredQueries
import StructuredQueriesSQLite

@Selection
public struct FirstOrSecond: Equatable, Identifiable, Sendable {
  public let name: String
  public let first: First?
  public let second: Second?
  
  public var id: String {
    if let first {
      "first-\(first.id)"
    } else if let second {
      "second-\(second.id)"
    } else {
      "unknown"
    }
  }
  
  public static func all() -> some Statement<FirstOrSecond> {
    let firstPart = First.select{ first in
      return FirstOrSecond.Columns(name: first.name, first: Optional(first))
    }
    let secondPart = Second.select{ second in
      return FirstOrSecond.Columns(name: second.name, second: Optional(second))
    }
    return With {
      firstPart.union(all: true, secondPart)
    } query: {
      FirstOrSecond.order{ $0.name }
    }
  }
}
