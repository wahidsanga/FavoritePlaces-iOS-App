//
//  Assignment2WaheedApp.swift
//  Assignment2Waheed
//
//  Created by Waheed Hasan on 29/4/2023.
//

import SwiftUI

@main
struct Assignment2WaheedApp: App {
    var model=PersistenceHandler.shared
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, model.container.viewContext)
        }
    }
}
