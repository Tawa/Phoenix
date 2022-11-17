import AccessibilityIdentifiers
import Factory
import Combine
import Component
import ComponentDetailsProviderContract
import SwiftUI

struct FamilySheetData {
    var family: Family
    let allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
    let allDependenciesSelectionValues: [String]
    let rules: [FamilyRule]
}

class FamilySheetPresenter: ObservableObject {
    @Injected(Container.familyFolderNameProvider) var familyFolderNameProvider
    @Published var viewData: FamilySheetData
    var name: String { viewData.family.name }
    var ignoreSuffix: Bool { viewData.family.ignoreSuffix }
    var folderName: String { viewData.family.folder ?? "" }
    var defaultFolderName: String { familyFolderNameProvider.folderName(forFamily: viewData.family.name) }
    var componentNameExample: String { "Component\(viewData.family.ignoreSuffix ? "" : viewData.family.name)" }
    var allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>] { viewData.allDependenciesConfiguration }
    var allDependenciesSelectionValues: [String] { viewData.allDependenciesSelectionValues }
    var rules: [FamilyRule] { viewData.rules }
    
    init(viewData: FamilySheetData) {
        self.viewData = viewData
    }
}

class FamilySheetInteractor {
    let familyFolderNameProvider: FamilyFolderNameProviderProtocol
    let getFamilySheetDataUseCase: GetFamilySheetDataUseCaseProtocol
    let selectFamilyUseCase: SelectFamilyUseCaseProtocol
    let updateFamilyUseCase: UpdateFamilyUseCaseProtocol

    var viewData: FamilySheetPresenter
    var subscription: AnyCancellable?

    init(familyFolderNameProvider: FamilyFolderNameProviderProtocol,
         getFamilySheetDataUseCase: GetFamilySheetDataUseCaseProtocol,
         selectFamilyUseCase: SelectFamilyUseCaseProtocol,
         updateFamilyUseCase: UpdateFamilyUseCaseProtocol) {
        self.familyFolderNameProvider = familyFolderNameProvider
        self.getFamilySheetDataUseCase = getFamilySheetDataUseCase
        self.selectFamilyUseCase = selectFamilyUseCase
        self.updateFamilyUseCase = updateFamilyUseCase

        self.viewData = .init(viewData: getFamilySheetDataUseCase.value)
        subscription = getFamilySheetDataUseCase
            .publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] viewData in
                self?.viewData.viewData = viewData
            })
    }
    
    func deselect() {
        subscription?.cancel()
        selectFamilyUseCase.deselect()
    }
    
    func update(family: Family) {
        updateFamilyUseCase.update(family: family)
    }
    
    func update(_ closure: (inout Family) -> Void) {
        var family = viewData.viewData.family
        closure(&family)
        updateFamilyUseCase.update(family: family)
    }
}

struct FamilyRule: Identifiable {
    var id: String { name }
    let name: String
    let enabled: Bool
}

struct FamilySheet: View {
    @ObservedObject var viewData: FamilySheetPresenter
    let interactor: FamilySheetInteractor
    
    init(interactor: FamilySheetInteractor) {
        self.viewData = interactor.viewData
        self.interactor = interactor
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Family: \(viewData.name)")
                    .font(.largeTitle)
                
                Toggle(isOn: Binding(get: { !viewData.ignoreSuffix },
                                     set: { _ in
                    interactor.update { family in
                        family.ignoreSuffix.toggle()
                    }
                })) {
                    Text("Append Component Name with Family Name. ")
                        .bold()
                    + Text("\nExample: \(viewData.componentNameExample)")
                        .font(.subheadline.italic())
                }.with(accessibilityIdentifier: FamilySheetIdentifiers.appendNameToggle)
                
                HStack {
                    Text("Folder Name:")
                    TextField("Default: (\(viewData.defaultFolderName))",
                              text: Binding(get: { viewData.folderName },
                                            set: { newValue in
                        interactor.update { family in
                            family.folder = newValue.isEmpty ? nil : newValue
                        }
                    }))
                    .with(accessibilityIdentifier: FamilySheetIdentifiers.folderNameTextField)
                    Button(action: {
                        interactor.update { family in
                            family.folder = nil
                        }
                    }) {
                        Text("Use Default")
                    }
                }
                
                Spacer().frame(height: 30)
                
                DependencyView<PackageTargetType, String>(
                    title: "Default Dependencies",
                    allTypes: viewData.allDependenciesConfiguration,
                    allSelectionValues: viewData.allDependenciesSelectionValues,
                    onUpdateTargetTypeValue: { (packageTargetType, value) -> Void in
                        interactor.update { family in
                            family.defaultDependencies[packageTargetType] = value
                        }
                    }
                )
                
                VStack(alignment: .leading) {
                    Text("Allow ") + Text(viewData.name).bold() + Text(" components to be used in:")
                    ForEach(viewData.rules) { rule in
                        Toggle(rule.name,
                               isOn: Binding(get: { rule.enabled },
                                             set: { enabled in
                            interactor.update { family in
                                if enabled {
                                    family.excludedFamilies.removeAll(where: { rule.name == $0 })
                                } else {
                                    family.excludedFamilies.append(rule.name)
                                    family.excludedFamilies.sort()
                                }
                            }
                        })
                        )
                    }
                }
                .padding()
                
                Button(action: interactor.deselect) {
                    Text("Done")
                }
                .keyboardShortcut(.cancelAction)
                .with(accessibilityIdentifier: FamilySheetIdentifiers.doneButton)
                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 600, maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}
