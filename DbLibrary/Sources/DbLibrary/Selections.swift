import Foundation
import StructuredQueries
import StructuredQueriesSQLite

@Selection
public struct FlattendRecords: Equatable, Identifiable, Sendable {
  public let id: Int
  public let first: First
  public let second: Second
  public let third: Third
  public let quantity: Decimal
  
  public static func all() -> Select<FlattendRecords.Selection.QueryValue, SecondThirdMapping, (Third, Second, First)> {
    SecondThirdMapping
      .join(Third.all) { mapping, third in
        mapping.thirdId.eq(third.id)
      }
      .join(Second.all) { mapping, third, second in
        mapping.secondId.eq(second.id)
      }
      .join(First.all) { mapping, third, second, first in
        second.firstId.eq(first.id)
      }
      .select { mapping, third, second, first in
        FlattendRecords.Columns(id: mapping.id, first: first, second: second, third: third, quantity: mapping.quantity)
      }
  }
}
