//
//  FavoritesScreen.swift
//  democracyaction
//
//  User favorites - migrated from DAFavoriteTableViewController
//

import SwiftUI
import SwiftData

struct FavoritesScreen: View {
    @Query private var favorites: [Favorite]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "즐겨찾기 없음",
                        systemImage: "star.slash",
                        description: Text("국회의원을 즐겨찾기에 추가하면 여기에 표시됩니다")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(favorites, id: \.id) { favorite in
                                if let person = favorite.person {
                                    NavigationLink(value: person) {
                                        HStack {
                                            PoliticianRow(person: person)

                                            // Notification indicator
                                            if favorite.isAlarmOn {
                                                Image(systemName: "bell.fill")
                                                    .foregroundStyle(.blue)
                                                    .font(.caption)
                                                    .padding(.trailing, 8)
                                            }
                                        }
                                    }
                                    .tint(.black)
                                    .id(favorite.id)
                                    .contextMenu {
//                                        Button {
//                                            toggleNotification(favorite)
//                                        } label: {
//                                            Label(
//                                                favorite.isAlarmOn ? "알림 끄기" : "알림 켜기",
//                                                systemImage: favorite.isAlarmOn ? "bell.slash" : "bell"
//                                            )
//                                        }

                                        Button(role: .destructive) {
                                            deleteFavorite(favorite)
                                        } label: {
                                            Label("삭제", systemImage: "trash")
                                        }
                                    }

                                    Divider()
                                        .padding(.leading, 74)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("즐겨찾기")
            .navigationDestination(for: Person.self) { person in
                PersonDetailScreen(person: person)
            }
        }
    }
    
    private func deleteFavorite(_ favorite: Favorite) {
        modelContext.delete(favorite)
        try? modelContext.save()
    }
    
    private func toggleNotification(_ favorite: Favorite) {
        favorite.isAlarmOn.toggle()
        try? modelContext.save()
        
        // TODO: Subscribe/unsubscribe from Firebase topic
        if let person = favorite.person {
            print("Toggle notification for \(person.name): \(favorite.isAlarmOn)")
        }
    }
}

#Preview {
    let schema = Schema([Person.self, Group.self, Phone.self, MessageTool.self, Web.self, Event.self, EventGroup.self, EventPerson.self, Favorite.self])
    let container = try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    // Add sample data
    let context = container.mainContext
    let group = Group(no: 1, name: "Sample Party")
    context.insert(group)
    
    let person1 = Person(no: 1, name: "Favorite Person 1", nameCharacters: "즐겨찾기1", nameFirstCharacter: "즐", nameFirstCharacters: "ㅈㄱㅊㄱ1")
    person1.area = "Seoul"
    person1.group = group
    context.insert(person1)
    
    let person2 = Person(no: 2, name: "Favorite Person 2", nameCharacters: "즐겨찾기2", nameFirstCharacter: "즐", nameFirstCharacters: "ㅈㄱㅊㄱ2")
    person2.area = "Busan"
    person2.group = group
    context.insert(person2)
    
    let fav1 = Favorite(isAlarmOn: true, person: person1)
    context.insert(fav1)
    
    let fav2 = Favorite(isAlarmOn: false, person: person2)
    context.insert(fav2)
    
    return FavoritesScreen()
        .modelContainer(container)
}
