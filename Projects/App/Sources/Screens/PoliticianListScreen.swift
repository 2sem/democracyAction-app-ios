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
    @Query private var allPersons: [Person]
    @EnvironmentObject private var adManager: SwiftUIAdManager

    @State private var isShowingDataUpdateIndicator = false
    @State private var sectionIDToScroll: String?
    
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
            .searchable(text: $viewModel.searchText, prompt: "이름 또는 지역구 검색")
            .searchScopes($viewModel.searchScope) {
                ForEach(PoliticianListViewModel.SearchScope.allCases, id: \.self) { scope in
                    Text(scope.title).tag(scope)
                }
            }
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    sectionJumpMenu
                }
            }
            .onChange(of: allPersons) { oldPersons, newPersons in
                viewModel.updateGroups(withPersons: newPersons)
            }
            .onChange(of: viewModel.groupingType) { _, _ in
                viewModel.updateGroups(withPersons: allPersons)
            }
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.debouncedRefresh(withPersons: allPersons) {}
            }.onChange(of: viewModel.searchScope) { _, _ in
                viewModel.debouncedRefresh(withPersons: allPersons) {}
            }
            .task {
                viewModel.updateGroups(withPersons: allPersons)
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailScreen(person: person)
            }
        }
    }
    
    func refresh() {
        viewModel.updateGroups(withPersons: allPersons)
    }
    
    @ViewBuilder
    private func emptyView() -> some View {
        if viewModel.searchText.isEmpty {
            ContentUnavailableView(
                "데이터 없음",
                systemImage: "person.slash",
                description: Text("국회의원 정보가 여기에 표시됩니다")
            )
        } else {
            ContentUnavailableView(
                "검색 결과가 없습니다",
                systemImage: "magnifyingglass",
                description: Text("이름이나 지역구를 다시 확인해 주세요")
            )
        }
    }
    
    @ViewBuilder
    private func listView() -> some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.groups) { group in //, id: \.id
                        Section(header: politicianSection(withGroup: group)) {
                            let nativeAdInterval = 10
                            ForEach(Array(group.persons.enumerated()), id: \.element.no) { index, person in
                                SwiftUI.Group {
                                    if !viewModel.searchText.isEmpty || group.persons.count >= 10 {
                                        NativeAdRowView(adUnit: .personListNative, index: index, interval: nativeAdInterval)
                                    }
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
            .overlay(alignment: .top) {
                if isShowingDataUpdateIndicator {
                    DataUpdateIndicator()
                        .background(Color(UIColor.systemBackground))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top < -8
            } action: { _, isPullingDown in
                withAnimation(.snappy(duration: 0.2)) {
                    isShowingDataUpdateIndicator = isPullingDown
                }
            }
            .onChange(of: sectionIDToScroll) { _, sectionID in
                guard let sectionID else { return }

                withAnimation {
                    scrollProxy.scrollTo(sectionID, anchor: .top)
                }

                sectionIDToScroll = nil
            }
            .id(viewModel.groupingType)
        }
    }
    
    @ViewBuilder
    private func politicianRow(person: Person, withGroupId groupId: String) -> some View {
        NavigationLink(value: person) {
            PoliticianRow(person: person)
        }
        .tint(.primary)
        .id(person.id.hashValue.description)
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

    private var sectionJumpMenu: some View {
        Menu {
            ForEach(viewModel.groups) { group in
                Button(group.title) {
                    sectionIDToScroll = group.id
                }
            }
        } label: {
            Image(systemName: "list.bullet")
        }
        .disabled(viewModel.groups.isEmpty)
        .accessibilityLabel("섹션 선택")
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
