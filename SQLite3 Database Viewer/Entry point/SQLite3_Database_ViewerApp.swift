//
//  SQLite3_Database_ViewerApp.swift
//  SQLite3 Database Viewer
//
//  Created by Tipu Sultan on 2/21/25.
//

import SwiftUI

@main
struct SQLite3_Database_ViewerApp: App {
    @StateObject private var dbManager = DatabaseManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(dbManager) // Inject database manager into the environment
        }
        .commands {
            CommandMenu("Database") {
                Button("Fetch Users") {
                    let users = dbManager.fetchUsers()
                    print("Users: \(users)")
                }
            }
        }
    }
}

