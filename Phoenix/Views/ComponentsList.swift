import AccessibilityIdentifiers
import Combine
import SwiftUI

struct ComponentsListRow: Hashable, Identifiable {
    let id: String
    let name: String
    let isSelected: Bool
    
    init(id: String,
         name: String,
         isSelected: Bool) {
        self.id = id
        self.name = name
        self.isSelected = isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isSelected)
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

struct ComponentsListSection: Hashable, Identifiable {
    var id: String { name }
    
    let name: String
    let folderName: String?
    let rows: [ComponentsListRow]
    
    var title: String {
        folderName.map { folderName in
            name + "(Folder: \(folderName)"
        } ?? name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(rows)
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

class ComponentsListViewData: ObservableObject {
    @Published var sections: [ComponentsListSection] = []
    
    init(sections: [ComponentsListSection]) {
        self.sections = sections
    }
}

class ComponentsListInteractor {
    let getComponentsListItemsUseCase: GetComponentsListItemsUseCaseProtocol
    let selectComponentUseCase: SelectComponentUseCaseProtocol
    var viewData: ComponentsListViewData = .init(sections: [])
    var subscription: AnyCancellable?
    
    init(getComponentsListItemsUseCase: GetComponentsListItemsUseCaseProtocol,
         selectComponentUseCase: SelectComponentUseCaseProtocol) {
        self.getComponentsListItemsUseCase = getComponentsListItemsUseCase
        self.selectComponentUseCase = selectComponentUseCase
        viewData.sections = getComponentsListItemsUseCase.list

        subscription = getComponentsListItemsUseCase
            .listPublisher
            .removeDuplicates()
            .sink(receiveValue: { [weak self] sections in
                self?.viewData.sections = sections
            })
    }
    
    func select(id: String) {
        selectComponentUseCase.select(id: id)
    }
}

struct ComponentsList: View {
    @ObservedObject var viewData: ComponentsListViewData
    let interactor: ComponentsListInteractor
    
    init(interactor: ComponentsListInteractor) {
        self.viewData = interactor.viewData
        self.interactor = interactor
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(viewData.sections) { section in
                    Section {
                        ForEach(section.rows) { row in
                            ComponentListItem(
                                name: row.name,
                                isSelected: row.isSelected,
                                onSelect: { interactor.select(id: row.id) },
                                onDuplicate: { }
                            )
                            .with(accessibilityIdentifier: ComponentsListIdentifiers.component(named: row.name))
                        }
                    } header: {
                        Button(action: {},
                               label: {
                            HStack {
                                Text(section.name)
                                    .font(.title)
                                section.folderName.map { folderName -> Text? in
                                    guard folderName != section.name else { return nil }
                                    return Text("(\(Image(systemName: "folder")) \(folderName))")
                                }?.help("Folder Name")
                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            }
                        })
                        .buttonStyle(.plain)
                        .padding(.vertical)
                        .with(accessibilityIdentifier: ComponentsListIdentifiers.familySettingsButton(named: section.name))
                    }
                    Divider()
                }
                Text(numberOfComponentsString)
                    .foregroundColor(.gray)
            }
            .frame(minHeight: 200, maxHeight: .infinity)
            .listStyle(SidebarListStyle())
        }
    }
    
    private var numberOfComponentsString: String {
        let totalRows = viewData.sections.flatMap(\.rows).count
        if totalRows == 1 {
            return "1 component"
        } else {
            return "\(totalRows) component"
        }
    }
}
