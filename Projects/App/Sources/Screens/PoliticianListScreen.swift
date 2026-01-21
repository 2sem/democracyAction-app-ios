//
//  PoliticianListScreen.swift
//  democracyaction
//
//  Politician directory list - migrated from DAInfoTableViewController
//

import SwiftUI
import SwiftData

struct PoliticianListScreen: View {
    @Query private var persons: [Person]
    @Query private var groups: [Group]
    
    @State private var searchText = ""
    @State private var selectedGroup: Group?
    
    var body: some View {
        NavigationStack {
            VStack {
                if persons.isEmpty {
                    ContentUnavailableView(
                        "데이터 없음",
                        systemImage: "person.slash",
                        description: Text("국회의원 정보가 여기에 표시됩니다")
                    )
                } else {
                    List {
                        ForEach(persons.prefix(20), id: \.no) { person in
                            PoliticianRow(person: person)
                        }
                    }
                }
            }
            .navigationTitle("국회의원")
            .searchable(text: $searchText, prompt: "이름 또는 지역 검색")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("전체") {
                            selectedGroup = nil
                        }
                        
                        ForEach(groups.prefix(10), id: \.no) { group in
                            Button(group.name) {
                                selectedGroup = group
                            }
                        }
                    } label: {
                        Label("필터", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}

#Preview {
    let schema = Schema([Person.self, Group.self, Phone.self, MessageTool.self, Web.self, Event.self, EventGroup.self, EventPerson.self, Favorite.self])
    let container = try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    // Add sample data
    let context = container.mainContext
    let group = Group(no: 1, name: "더불어민주당")
    context.insert(group)
    
    let person1 = Person(no: 1, name: "홍길동", nameCharacters: "홍길동", nameFirstCharacter: "홍", nameFirstCharacters: "ㅎㄱㄷ")
    person1.area = "서울 강남구 갑"
    person1.group = group
    context.insert(person1)
    
    let person2 = Person(no: 2, name: "김철수", nameCharacters: "김철수", nameFirstCharacter: "김", nameFirstCharacters: "ㄱㅊㅅ")
    person2.area = "부산 해운대구 을"
    person2.group = group
    context.insert(person2)
    
    return PoliticianListScreen()
        .modelContainer(container)
}
