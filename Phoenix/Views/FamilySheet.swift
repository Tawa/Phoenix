import AccessibilityIdentifiers
import Combine
import Component
import ComponentDetailsProviderContract
import SwiftUI

class FamilySheetViewData: ObservableObject {
    @Published var name: String
    @Published var ignoreSuffix: Bool
    @Published var folderName: String
    @Published var defaultFolderName: String
    @Published var componentNameExample: String
    @Published var allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
    @Published var allDependenciesSelectionValues: [String]
    @Published var onUpdateTargetTypeValue: (PackageTargetType, String?) -> Void
    @Published var rules: [FamilyRule]
    @Published var onUpdateFamilyRule: (String, Bool) -> Void
    
    init(family: Family,
         name: String = "",
         ignoreSuffix: Bool = false,
         folderName: String = "",
         defaultFolderName: String = "",
         componentNameExample: String = "",
         allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>] = [],
         allDependenciesSelectionValues: [String] = [],
         onUpdateTargetTypeValue: @escaping (PackageTargetType, String?) -> Void = { _, _ in },
         rules: [FamilyRule] = [],
         onUpdateFamilyRule: @escaping (String, Bool) -> Void = { _, _ in }) {
        self.name = name
        self.ignoreSuffix = ignoreSuffix
        self.folderName = folderName
        self.defaultFolderName = defaultFolderName
        self.componentNameExample = componentNameExample
        self.allDependenciesConfiguration = allDependenciesConfiguration
        self.allDependenciesSelectionValues = allDependenciesSelectionValues
        self.onUpdateTargetTypeValue = onUpdateTargetTypeValue
        self.rules = rules
        self.onUpdateFamilyRule = onUpdateFamilyRule
    }
    /*
     FamilySheet(
         allDependenciesConfiguration: allDependenciesConfiguration(defaultDependencies: family.defaultDependencies),
         allDependenciesSelectionValues: allDependenciesSelectionValues(),
         onUpdateTargetTypeValue: {
             document.updateDefaultdependencyForFamily(
                 named: family.name,
                 packageType: $0,
                 value: $1)
         },
         rules: document.families.map(\.family).filter { $0 != family }.map { otherFamily in
             FamilyRule(
                 name: otherFamily.name,
                 enabled: !family.excludedFamilies.contains(where: { otherFamily.name == $0 })
             )
         }, onUpdateFamilyRule: { name, enabled in
             document.updateFamilyRule(withName: family.name, otherFamilyName: name, enabled: enabled)
         },
         onDismiss: { viewModel.selectedFamilyName = nil })
     */
}

class FamilySheetInteractor {
    let familyFolderNameProvider: FamilyFolderNameProviderProtocol
    let getSelectedFamilyUseCase: GetSelectedFamilyUseCaseProtocol
    let selectFamilyUseCase: SelectFamilyUseCaseProtocol
    let updateFamilyUseCase: UpdateFamilyUseCaseProtocol

    var family: Family
    var viewData: FamilySheetViewData
    var subscription: AnyCancellable?

    init(familyFolderNameProvider: FamilyFolderNameProviderProtocol,
         getSelectedFamilyUseCase: GetSelectedFamilyUseCaseProtocol,
         selectFamilyUseCase: SelectFamilyUseCaseProtocol,
         updateFamilyUseCase: UpdateFamilyUseCaseProtocol) {
        self.familyFolderNameProvider = familyFolderNameProvider
        self.selectFamilyUseCase = selectFamilyUseCase
        self.getSelectedFamilyUseCase = getSelectedFamilyUseCase
        self.updateFamilyUseCase = updateFamilyUseCase

        family = getSelectedFamilyUseCase.family
        self.viewData = .init(family: family)
        self.reloadViewData(family: family)
        
        subscription = getSelectedFamilyUseCase
            .familyPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] family in
                self?.reloadViewData(family: family)
            })
    }
    
    func deselect() {
        selectFamilyUseCase.deselect()
    }
    
    func update(family: Family) {
        updateFamilyUseCase.update(family: family)
    }
    
    private func reloadViewData(family: Family) {
        self.family = family
        
        viewData.name = family.name
        viewData.ignoreSuffix = family.ignoreSuffix
        viewData.folderName = family.folder ?? ""
        viewData.defaultFolderName = familyFolderNameProvider.folderName(forFamily: family.name)
        viewData.componentNameExample = "Component\(family.ignoreSuffix ? "" : family.name)"
    }
}

struct FamilyRule: Identifiable {
    var id: String { name }
    let name: String
    let enabled: Bool
}

struct FamilySheet: View {
    @ObservedObject var viewData: FamilySheetViewData
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
                    var family = interactor.family
                    family.ignoreSuffix.toggle()
                    interactor.update(family: family)
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
                                            set: {
                        var family = interactor.family
                        family.folder = $0.isEmpty ? nil : $0
                        interactor.update(family: family)
                    }))
                    .with(accessibilityIdentifier: FamilySheetIdentifiers.folderNameTextField)
                    Button(action: {
                        var family = interactor.family
                        family.folder = nil
                        interactor.update(family: family)
                    }) {
                        Text("Use Default")
                    }
                }
                
                Spacer().frame(height: 30)
                
                DependencyView<PackageTargetType, String>(
                    title: "Default Dependencies",
                    allTypes: viewData.allDependenciesConfiguration,
                    allSelectionValues: viewData.allDependenciesSelectionValues,
                    onUpdateTargetTypeValue: viewData.onUpdateTargetTypeValue)
                
                
                VStack(alignment: .leading) {
                    Text("Allow ") + Text(viewData.name).bold() + Text(" components to be used in:")
                    ForEach(viewData.rules) { rule in
                        Toggle(rule.name,
                               isOn: Binding(get: { rule.enabled },
                                             set: { viewData.onUpdateFamilyRule(rule.name, $0) })
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
