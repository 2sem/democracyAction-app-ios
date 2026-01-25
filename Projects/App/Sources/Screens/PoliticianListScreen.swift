//
//  PoliticianListScreen.swift
//  democracyaction
//
//  Politician directory list - migrated from DAInfoTableViewController
//

import SwiftUI
import SwiftData

struct PoliticianListScreen: View {
    @StateObject private var viewModel = PoliticianListViewModel()
    @State var visibleGroupIds: Set<String> = []
    @Query private var allPersons: [Person]
    @EnvironmentObject private var adManager: SwiftUIAdManager

    @State var lastVisibleGroupID: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.groups.isEmpty {
                    emptyView()
                } else {
                    listView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "이름 또는 지역 검색")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if let url = URL(string: "https://open.kakao.com/o/g1jk9Xx") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                    }
                }
                
                // Grouping Type Picker - moved to toolbar
                ToolbarItem(placement: .principal) {
                    Picker("그룹핑", selection: $viewModel.groupingType) {
                        ForEach(PoliticianListViewModel.GroupingType.allCases, id: \.self) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Sort toggle button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.toggleSort()
                    } label: {
                        Image(systemName: viewModel.sortIconName)
                    }
                }
            }
            .onChange(of: allPersons) { oldPersons, newPersons in
                refersh()
            }
            .onChange(of: viewModel.groupingType, { _, _ in
                refersh()
            })
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                refersh()
            }
            .task {
                refersh()
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailScreen(person: person)
            }
        }
    }
    
    func refersh() {
        visibleGroupIds = []
        viewModel.updateGroups(withPersons: allPersons)
        updateLastVisibleGroupID()
    }
    
    @ViewBuilder
    private func emptyView() -> some View {
        ContentUnavailableView(
            "데이터 없음",
            systemImage: "person.slash",
            description: Text("국회의원 정보가 여기에 표시됩니다")
        )
    }
    
    @ViewBuilder
    private func listView() -> some View {
        ScrollViewReader { scrollProxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack() {
                        ForEach(viewModel.groups) { group in //, id: \.id
                            Section(header: politicianSection(withGroup: group)) {
                                let nativeAdInterval = 10
                                ForEach(Array(group.persons.enumerated()), id: \.element.no) { index, person in
                                    SwiftUI.Group {
                                        NativeAdRowView(index: index, interval: nativeAdInterval)
                                        politicianRow(person: person, withGroupId: group.id)
                                    }
                                }
                            }
                            .id(group.id)
                        }
                    }
                    .scrollTargetLayout()
                    .padding()
                }
                .listStyle(.plain)
                .onScrollTargetVisibilityChange(idType: String.self, threshold: 0.5) { visibleIds in
                    visibleGroupIds = Set(viewModel.getGroupIds(fromIds: visibleIds))
                    updateLastVisibleGroupID()
                }

                nextSectionButton(scrollProxy: scrollProxy)
            }
            .id(viewModel.groupingType)
        }
    }
    
    @ViewBuilder
    private func politicianRow(person: Person, withGroupId groupId: String) -> some View {
        NavigationLink(value: person) {
            PoliticianRow(person: person)
        }
        .tint(.black)
        .id(person.id.hashValue.description)
//            .onScrollVisibilityChange(threshold: 0.5) { isVisible in
//                if isVisible {
//                    // Add person to group's visible set
//                    visiblePersonIds[groupId, default: []].insert(person.no)
//                    
//                    print("Visible person: \(person.no) group: \(groupId)")
//                } else {
//                    print("Invisible person: \(person.no) group: \(groupId)")
//                    // Remove person from group's visible set
//                    visiblePersonIds[groupId]?.remove(person.no)
//
//                    // If no persons are visible in this group, remove the group
//                    if visiblePersonIds[groupId]?.isEmpty == true {
//                        visiblePersonIds.removeValue(forKey: groupId)
//                        print("Invisible group: \(groupId)")
//                    }
//                }
//
//                // Update last visible group
//                updateLastVisibleGroupID()
//            }
    }
    
    @ViewBuilder
    private func politicianSection(withGroup group: PoliticianListViewModel.PersonGroup) -> some View {
        if viewModel.groupingType == .byGroup, let partyGroup = group.group {
            // Show special party header with call/SNS/search buttons
            PartyHeaderView(group: partyGroup)
                .id(group.id)
        } else {
            // Regular text header for name/area grouping
            Text(group.title)
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray6))
                .id(group.id)
        }
    }

        @ViewBuilder

        private func nextSectionButton(scrollProxy: ScrollViewProxy) -> some View {

            // Next section floating button

            if let lastVisibleGroupID, let nextGroup = viewModel.nextGroup(ofGroupWithId: lastVisibleGroupID) {

                Button {

                    withAnimation {

                        scrollProxy.scrollTo(nextGroup.id, anchor: .top)

                    }

                } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                    Text(nextGroup.title)
                        .font(.system(size: viewModel.groupingType == .byName ? 20 : 14, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                .foregroundColor(.white)
//                .frame(width: viewModel.groupingType == .byName ? 60 : 88, height: 44)
                .background(Color(red: 0.47, green: 0.56, blue: 0.61)) // #78909c
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }
    }
    
    func updateLastVisibleGroupID() {
        // Find the last visible group by their actual order in viewModel.groups
        let lastVisibleGroupId = visibleGroupIds
            .sorted(by: { leftId, rightId in
                if viewModel.isAscending {
                    return leftId < rightId
                } else {
                    return leftId > rightId
                }
            })
            .last

        self.lastVisibleGroupID = lastVisibleGroupId
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
