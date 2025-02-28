//
//  DatabaseManager.swift
//  SQLite3 Database Viewer
//
//  Created by Tipu Sultan on 2/21/25.
//

import Foundation
import SQLite3

class DatabaseManager: ObservableObject {
    var db: OpaquePointer?
    @Published var users: [String] = [] // Observable users list

    init() {
        openDatabase()
        createTable()
        fetchUsers() // Load users when app starts
    }

    func openDatabase() {
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("mydb.sqlite")
        
        print("Database path: \(fileURL.path)") // Debug print for database path
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        } else {
            print("Database opened successfully")
        }
    }

    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Table created or already exists successfully.")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Table creation failed: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Preparation failed: \(errorMessage)")
        }
        sqlite3_finalize(statement)
    }


    func insertUser(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            print("❌ Name is empty or whitespace, cannot insert user.")
            return
        }
        
        print("✅ Attempting to insert name: '\(trimmedName)'") // Debugging
        
        let insertString = "INSERT INTO Users (name) VALUES (?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertString, -1, &statement, nil) == SQLITE_OK {
            // Bind trimmedName as a C string using the correct destructor type
            if sqlite3_bind_text(statement, 1, trimmedName, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self)) == SQLITE_OK {
                print("🔹 Successfully bound name: \(trimmedName)")
            } else {
                print("❌ Failed to bind name")
            }

            if sqlite3_step(statement) == SQLITE_DONE {
                print("✅ Inserted successfully: \(trimmedName)")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("❌ Insert failed: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("❌ Preparation failed: \(errorMessage)")
        }

        sqlite3_finalize(statement)
        
        fetchUsers() // Refresh users list
    }





    func fetchUsers() {
        let queryString = "SELECT name FROM Users;"
        var statement: OpaquePointer?
        var fetchedUsers: [String] = []

        if sqlite3_prepare_v2(db, queryString, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let cString = sqlite3_column_text(statement, 0) {
                    let userName = String(cString: cString)
                    
                    if userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        print("⚠️ Warning: Found an empty string in the database, ignoring.")
                    } else {
                        fetchedUsers.append(userName)
                        print("✅ Fetched user: \(userName)")
                    }
                } else {
                    print("⚠️ Warning: NULL value found in database.")
                }
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("❌ Query preparation failed: \(errorMessage)")
        }

        sqlite3_finalize(statement)

        DispatchQueue.main.async {
            self.users = fetchedUsers
            print("📌 Fetched users array: \(self.users)")
        }
    }




}
