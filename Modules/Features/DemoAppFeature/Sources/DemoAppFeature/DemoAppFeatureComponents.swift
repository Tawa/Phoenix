import Component
import ComponentDetailsProviderContract
import DemoAppGeneratorContract
import PBXProjectSyncerContract
import PhoenixDocument
import SwiftPackage
import SwiftUI

public struct DemoAppDependencyTargetType: Identifiable {
    public var id = UUID().uuidString
    
    let targetType: String
    var isSelected: Bool
    
    mutating func toggleSelection() {
        isSelected.toggle()
    }
}

public struct DemoAppDependencyViewModel: Identifiable {
    public var id = UUID().uuidString
    
    let title: String
    var targetTypes: [DemoAppDependencyTargetType]
}

struct DemoAppDependencySelection: Hashable {
    let title: String
    let targetType: String
}

struct DemoAppDependenciesViewModel {
    let dependencies: [DemoAppDependencyViewModel]
    var selections: Set<DemoAppDependencySelection>
}

class DemoAppFeatureViewModel: ObservableObject {
    let title: String
    @Published var organizationIdentifier: String = ""
    @Published var isListLoading: Bool = false
    @Published var dependencySections: [DemoAppDependencySection] = []
    @Published var selections: Set<DemoAppDependencySelection> = .init()
    
    init(
        title: String,
        organizationIdentifier: String
    ) {
        self.title = title
        self.organizationIdentifier = organizationIdentifier
    }
}


struct DemoAppFeaturePresenter {
    let viewModel: DemoAppFeatureViewModel
    
    func startLoadingList() {
        viewModel.isListLoading = true
    }
    
    func stopLoadingList() {
        viewModel.isListLoading = false
    }
    
    func update(dependencySections: [DemoAppDependencySection]) {
        viewModel.dependencySections = dependencySections
    }
}

class DemoAppFeatureInteractor {
    private let ashFileURL: URL
    private let component: Component
    private let demoAppGenerator: DemoAppGeneratorProtocol
    private let document: PhoenixDocument
    private let packageFolderNameProvider: PackageFolderNameProviderProtocol
    private let packageNameProvider: PackageNameProviderProtocol
    private let pbxProjectSyncer: PBXProjectSyncerProtocol
    private let presenter: DemoAppFeaturePresenter
    private let cancelAction: () -> Void
    private let onError: (Error) -> Void
    
    private lazy var selections: Set<DemoAppDependencySelection> = {
        var selections = Set<DemoAppDependencySelection>()
        add(dependencyNamed: component.name, toSelection: &selections)
        return selections
    }()
    
    init(
        ashFileURL: URL,
        component: Component,
        document: PhoenixDocument,
        packageFolderNameProvider: PackageFolderNameProviderProtocol,
        packageNameProvider: PackageNameProviderProtocol,
        pbxProjectSyncer: PBXProjectSyncerProtocol,
        presenter: DemoAppFeaturePresenter,
        demoAppGenerator: DemoAppGeneratorProtocol,
        cancelAction: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) {
        self.ashFileURL = ashFileURL
        self.component = component
        self.demoAppGenerator = demoAppGenerator
        self.document = document
        self.packageFolderNameProvider = packageFolderNameProvider
        self.packageNameProvider = packageNameProvider
        self.pbxProjectSyncer = pbxProjectSyncer
        self.presenter = presenter
        self.cancelAction = cancelAction
        self.onError = onError
    }
    
    func onGenerate() {
        guard let url = openFolderSelection()
        else { return }
        generate(at: url)
    }
    
    private func generate(at url: URL) {
        let allFamilies: [Family] = document.families.map { $0.family }
        guard let family = allFamilies.first(where: { $0.name == component.name.family })
        else { return }
        do {
            let name = packageNameProvider.packageName(
                forComponentName: component.name,
                of: family,
                packageConfiguration: PackageConfiguration(name: "", appendPackageName: false, hasTests: false)
            ) + "Demo"
            
            let result = try demoAppGenerator.generateDemoApp(named: name,
                                                              at: url)
            
            try pbxProjectSyncer.sync(document: getResultDocument(),
                                      at: ashFileURL,
                                      withProjectAt: result.xcodeProjURL)
        } catch {
            onError(error)
        }
        
    }
    
    private func getResultDocument() -> PhoenixDocument {
        var document = document
        document.families = document.families.compactMap { componentsFamily in
            let components = componentsFamily.components.compactMap { component -> Component? in
                let modules = component.modules.reduce(into: [String: LibraryType](), {
                    let dependencySelection = DemoAppDependencySelection(
                        title: packageNameProvider.packageName(
                            forComponentName: component.name,
                            of: componentsFamily.family,
                            packageConfiguration: .init(name: "", appendPackageName: false, hasTests: false)),
                        targetType: $1.key)
                    guard selections.contains(dependencySelection) else { return }
                    $0[$1.key] = $1.value
                })
                guard !modules.isEmpty else { return nil }
                var component = component
                component.modules = modules
                return component
            }
            guard !components.isEmpty else { return nil }
            var componentsFamily = componentsFamily
            componentsFamily.components = components
            return componentsFamily
        }
        return document
    }
    
    private func add(dependencyNamed name: Name, toSelection selections: inout Set<DemoAppDependencySelection>) {
        guard let componentsFamily = document.families.first(where: { $0.family.name == name.family })
        else { return }
        guard let component = componentsFamily.components.first(where: { $0.name == name })
        else { return }
        
        let family = componentsFamily.family
        
        var alreadyExists = false
        for targetType in component.modules.keys {
            let title = packageNameProvider.packageName(forComponentName: component.name,
                                                        of: family,
                                                        packageConfiguration: .init(name: "", appendPackageName: false, hasTests: false))
            
            let selection = DemoAppDependencySelection(title: title, targetType: targetType)
            if selections.contains(selection) {
                alreadyExists = true
                break
            } else {
                selections.insert(selection)
            }
        }
        guard !alreadyExists else { return }
        
        component.localDependencies.map(\.name)
            .forEach { add(dependencyNamed: $0, toSelection: &selections) }
    }
    
    func onAppear() {
        presenter.startLoadingList()
        
        refreshSections()
        
        presenter.stopLoadingList()
    }
    
    private func refreshSections() {
        DispatchQueue.global(qos: .background).async { [self] in
            let dependencySections: [DemoAppDependencySection] = document.families.map { componentsFamily in
                let title = packageFolderNameProvider.folderName(for: componentsFamily.family)
                
                let rows: [DemoAppDependencyRow] = componentsFamily.components.map { component in
                    let rowTitle = packageNameProvider.packageName(forComponentName: component.name,
                                                                   of: componentsFamily.family,
                                                                   packageConfiguration: PackageConfiguration(name: "", appendPackageName: false, hasTests: false))
                    
                    let subrows: [DemoAppDependencySubrow] = component.modules.keys.sorted().map { moduleType in
                        let dependencySelection = DemoAppDependencySelection(
                            title: packageNameProvider.packageName(
                                forComponentName: component.name,
                                of: componentsFamily.family,
                                packageConfiguration: .init(name: "", appendPackageName: false, hasTests: false)),
                            targetType: moduleType)
                        
                        return DemoAppDependencySubrow(title: moduleType,
                                                       selected: self.selections.contains(dependencySelection),
                                                       onToggleSelection: { [weak self] newValue in
                            guard let self = self else { return }
                            if newValue {
                                self.selections.insert(dependencySelection)
                            } else {
                                self.selections.remove(dependencySelection)
                            }
                            self.refreshSections()
                        })
                    }
                    
                    return DemoAppDependencyRow(title: rowTitle,
                                                subrows: subrows)
                }
                
                return DemoAppDependencySection(title: title,
                                                rows: rows)
            }
            DispatchQueue.main.async { [self] in
                presenter.update(dependencySections: dependencySections)
            }
        }
    }
    
    func onCancel() {
        cancelAction()
    }
    
    // MARK: - Private
    private func openFolderSelection() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = ashFileURL
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = true
        openPanel.allowedContentTypes = []
        
        openPanel.runModal()
        return openPanel.url
    }
    
}
