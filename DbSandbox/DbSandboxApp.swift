import ComposableArchitecture
import DbLibrary
import SQLiteData
import SwiftUI

@main
struct DbSandboxApp: App {
  init() {
    prepareDependencies {
      $0.defaultDatabase = try! appDatabase()
    }
  }
  
  var body: some Scene {
    WindowGroup {
      DbView(store: Store(initialState: DbFeature.State()) {
        DbFeature()
      })
    }
  }
}
