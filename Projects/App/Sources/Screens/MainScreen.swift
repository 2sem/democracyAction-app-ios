//
//  MainScreen.swift
//  democracyaction
//
//  Main tab navigation - 2 tabs: Politicians and Favorites
//

import SwiftUI
import SwiftData

struct MainScreen: View {
    var body: some View {
        TabView {
            PoliticianListScreen()
                .tabItem {
                    Label("국회의원", systemImage: "person.3.fill")
                }
            
            FavoritesScreen()
                .tabItem {
                    Label("즐겨찾기", systemImage: "star.fill")
                }
        }
    }
}

#Preview {
    let schema = Schema([Person.self, Group.self, Phone.self, MessageTool.self, Web.self, Event.self, EventGroup.self, EventPerson.self, Favorite.self])
    let container = try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    return MainScreen()
        .modelContainer(container)
}
