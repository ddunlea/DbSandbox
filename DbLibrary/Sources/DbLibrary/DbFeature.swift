import ComposableArchitecture
import Foundation
import OSLog
import SQLiteData
import StructuredQueries
import StructuredQueriesCore
import SwiftUI

@Reducer
public struct DbFeature {
  @Dependency(\.defaultDatabase) var defaultDatabase
  
  public init() {}
  
  @ObservableState
  public struct State {
    public init() {}
  }
}

public struct DbView: View {
  @Bindable var store: StoreOf<DbFeature>
  
  public init(store: StoreOf<DbFeature>) {
    self.store = store
  }
  
  public var body: some View {
    Text("Hello World")
  }
}
