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
}

struct ComponentsListSection: Hashable, Identifiable {
    let id: String
    
    let name: String
    let folderName: String?
    let rows: [ComponentsListRow]
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
    let selectFamilyUseCase: SelectFamilyUseCaseProtocol
    var viewData: ComponentsListViewData = .init(sections: [])
    var subscription: AnyCancellable?
    
    init(getComponentsListItemsUseCase: GetComponentsListItemsUseCaseProtocol,
         selectComponentUseCase: SelectComponentUseCaseProtocol,
         selectFamilyUseCase: SelectFamilyUseCaseProtocol) {
        self.getComponentsListItemsUseCase = getComponentsListItemsUseCase
        self.selectComponentUseCase = selectComponentUseCase
        self.selectFamilyUseCase = selectFamilyUseCase

        viewData = .init(sections: getComponentsListItemsUseCase.list)
        subscription = getComponentsListItemsUseCase
            .listPublisher
            .filter { [weak self] in self?.viewData.sections != $0}
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] sections in
                self?.viewData.sections = sections
            })
    }
    
    func select(id: String) {
        selectComponentUseCase.select(id: id)
    }
    
    func selectFamily(id: String) {
        selectFamilyUseCase.select(id: id)
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
                        Button(action: { interactor.selectFamily(id: section.id) },
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
