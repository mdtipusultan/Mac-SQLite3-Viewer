//
//  ContentView.swift
//  SQLite3 Database Viewer
//
//  Created by Tipu Sultan on 2/21/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dbManager: DatabaseManager
    @State private var userName: String = ""

    var body: some View {
        VStack {
            Text("SQLite3 Database Viewer")
                .font(.largeTitle)
                .padding()

            TextField("Enter name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Add User") {
                dbManager.insertUser(name: userName)
                userName = "" // Clear input field
                print(dbManager.users)
            }
            .padding()

            // Replace List with ZStack
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(dbManager.users, id: \.self) { user in
                        ZStack {
                            // Rounded Rectangle Background
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
                            
                            // Content
                            HStack(spacing: 12) {
                                Text(user) // Display user name
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding()
                        }
                        .frame(height: 60) // Adjust the height as needed
                    }
                }
                .padding()
            }

            Button("Load Users") {
                dbManager.fetchUsers()
            }
            .padding()
        }
        .frame(width: 400, height: 400)
        .onAppear {
            dbManager.fetchUsers()
        }
    }
}

// Preview
#Preview {
    HomeView()
        .environmentObject(DatabaseManager()) // Inject environment object for preview
}
