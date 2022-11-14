import AccessibilityIdentifiers
import Component
import SwiftUI

class FamilySheetViewData: ObservableObject {
    @Published var name: String
    @Published var ignoreSuffix: Bool
    @Published var onUpdateSelectedFamily: (Bool) -> Void
    @Published var folderName: String
    @Published var onUpdateFolderName: (String?) -> Void
    @Published var defaultFolderName: String
    @Published var componentNameExample: String
    @Published var allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
    @Published var allDependenciesSelectionValues: [String]
    @Published var onUpdateTargetTypeValue: (PackageTargetType, String?) -> Void
    @Published var rules: [FamilyRule]
    @Published var onUpdateFamilyRule: (String, Bool) -> Void
    
    init(name: String = "",
         ignoreSuffix: Bool = false,
         onUpdateSelectedFamily: @escaping (Bool) -> Void = { _ in },
         folderName: String = "",
         onUpdateFolderName: @escaping (String?) -> Void = { _ in },
         defaultFolderName: String = "",
         componentNameExample: String = "",
         allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>] = [],
         allDependenciesSelectionValues: [String] = [],
         onUpdateTargetTypeValue: @escaping (PackageTargetType, String?) -> Void = { _, _ in },
         rules: [FamilyRule] = [],
         onUpdateFamilyRule: @escaping (String, Bool) -> Void = { _, _ in }) {
        self.name = name
        self.ignoreSuffix = ignoreSuffix
        self.onUpdateSelectedFamily = onUpdateSelectedFamily
        self.folderName = folderName
        self.onUpdateFolderName = onUpdateFolderName
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
         name: family.name,
         ignoreSuffix: family.ignoreSuffix,
         onUpdateSelectedFamily: { document.updateFamily(withName: family.name, ignoresSuffix: !$0) },
         folderName: family.folder ?? "",
         onUpdateFolderName: { document.updateFamily(withName: family.name, folder: $0) },
         defaultFolderName: viewModel.folderName(forFamily: family.name),
         componentNameExample: "Component\(family.ignoreSuffix ? "" : family.name)",
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
    let selectFamilyUseCase: SelectFamilyUseCaseProtocol
    var viewData: FamilySheetViewData
    
    init(selectFamilyUseCase: SelectFamilyUseCaseProtocol) {
        self.selectFamilyUseCase = selectFamilyUseCase
        self.viewData = FamilySheetViewData()
    }
    
    func deselect() {
        selectFamilyUseCase.deselect()
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
                                     set: { viewData.onUpdateSelectedFamily($0) })) {
                    Text("Append Component Name with Family Name. ")
                        .bold()
                    + Text("\nExample: \(viewData.componentNameExample)")
                        .font(.subheadline.italic())
                }.with(accessibilityIdentifier: FamilySheetIdentifiers.appendNameToggle)
                
                HStack {
                    Text("Folder Name:")
                    TextField("Default: (\(viewData.defaultFolderName))",
                              text: Binding(get: { viewData.folderName },
                                            set: { viewData.onUpdateFolderName($0) }))
                    .with(accessibilityIdentifier: FamilySheetIdentifiers.folderNameTextField)
                    Button(action: { viewData.onUpdateFolderName(nil) }) {
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
