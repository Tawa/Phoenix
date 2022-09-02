import Factory
import Package
import PhoenixDocument
import SwiftUI
import DemoAppGeneratorContract
import PackageGeneratorContract
import ComponentPackagesProviderContract
import PBXProjectSyncerContract
import UniformTypeIdentifiers

enum ComponentPopupState: Hashable, Identifiable {
    var id: Int { hashValue }
    case new
    case template(Component)
}

enum AlertState: Hashable, Identifiable {
    var id: Int { hashValue }
    case errorString(String)
    
    var title: String {
        switch self {
        case let .errorString(value):
            return value
        }
    }
}

class ViewModel: ObservableObject {
    // MARK: - Selection
    @Published var selectedComponentName: Name? = nil
    @Published var selectedFamilyName: String? = nil
    
    // MARK: - Popovers
    @Published var showingConfigurationPopup: Bool = false
    @Published var showingNewComponentPopup: ComponentPopupState? = nil
    @Published var showingDependencyPopover: Bool = false
    @Published var alertState: AlertState? = nil
    
    // MARK: - Filters
    @Published var componentsListFilter: String = ""
    
    private var pathsCache: [URL: URL] = [:]
    
    func update(value: String) {
        print("Value: \(value)")
    }
    
    func onConfigurationButton() {
        showingConfigurationPopup = true
    }
    
    func onAddButton() {
        showingNewComponentPopup = .new
    }
    
    func onDuplicate(component: Component) {
        showingNewComponentPopup = .template(component)
    }
    
    func onAddAll(document: inout PhoenixDocument) {
        var componentsFamilies = document.families
        for familyIndex in 0..<10 {
            let familyName = "Family\(familyIndex)"
            var family = ComponentsFamily(family: Family(name: familyName,
                                                         ignoreSuffix: false,
                                                         folder: nil),
                                          components: [])
            for componentIndex in 0..<20 {
                family.components.append(Component(name: Name(given: "Component\(componentIndex)", family: familyName),
                                                   iOSVersion: nil,
                                                   macOSVersion: nil,
                                                   modules: document.projectConfiguration.packageConfigurations.reduce(into: [String: LibraryType](), { partialResult, packageConfiguration in
                    partialResult[packageConfiguration.name] = .undefined
                }),
                                                   dependencies: [],
                                                   resources: []))
            }
            componentsFamilies.append(family)
        }
        document.families = componentsFamilies
    }
    
    func onUpArrow() {
    }
    
    func onDownArrow() {
        
    }
    
    func onGenerate(document: PhoenixDocument, withFileURL fileURL: URL?) {
        guard let fileURL = fileURL else {
            alertState = .errorString("File must be saved before packages can be generated.")
            return
        }
        let componentExtractor = Container.componentPackagesProvider(document.projectConfiguration.swiftVersion)
        let allFamilies: [Family] = document.families.map { $0.family }
        let packagesWithPath: [PackageWithPath] = document.families.flatMap { componentFamily -> [PackageWithPath] in
            let family = componentFamily.family
            return componentFamily.components.flatMap { (component: Component) -> [PackageWithPath] in
                componentExtractor.packages(for: component,
                                            of: family,
                                            allFamilies: allFamilies,
                                            projectConfiguration: document.projectConfiguration)
            }
        }
        
        let packagesGenerator: PackageGeneratorProtocol = Container.packageGenerator()
        guard let folderURL = getPath(for: fileURL) else { return }
        for packageWithPath in packagesWithPath {
            let url = folderURL.appendingPathComponent(packageWithPath.path, isDirectory: true)
            do {
                try packagesGenerator.generate(package: packageWithPath.package, at: url)
            } catch {
                print(error)
            }
        }
    }
    
    func onGenerateDemoProject(for component: Component, from document: PhoenixDocument, ashFileURL: URL?) {
        guard let ashFileURL = ashFileURL else {
            alertState = .errorString("File must be saved before packages can be generated.")
            return
        }

        guard
            let url = openFolderSelection(at: nil)
        else { return }
        let allFamilies: [Family] = document.families.map { $0.family }
        guard let family = allFamilies.first(where: { $0.name == component.name.family })
        else {
            alertState = .errorString("Error getting Component Family.")
            return
        }
        
        let demoAppGenerator: DemoAppGeneratorProtocol = Container.demoAppGenerator()
        do {
            try demoAppGenerator.generateDemoApp(
                forComponent: component,
                of: family,
                families: document.families,
                projectConfiguration: document.projectConfiguration,
                at: url,
                relativeURL: ashFileURL)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func onSyncPBXProj(for document: PhoenixDocument, ashFileURL: URL?) {
        guard let ashFileURL = ashFileURL else {
            alertState = .errorString("File must be saved before packages can be generated.")
            return
        }
        
        guard
            let xcodeProj = openFolderSelection(at: ashFileURL, fileExtensions: ["xcodeproj"])
        else { return }
        
        let syncer = Container.pbxProjSyncer()
        do {
            try syncer.sync(document: document, at: ashFileURL, withProjectAt: xcodeProj)
        } catch {
            alertState = .errorString(error.localizedDescription)
        }
    }
    
    private func openFolderSelection(at fileURL: URL?, fileExtensions: [String]? = nil) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = fileURL?.deletingLastPathComponent()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        openPanel.canCreateDirectories = true
        openPanel.allowedContentTypes = []
        
        openPanel.runModal()
        return openPanel.url
    }
    
    private func getPath(for fileURL: URL) -> URL? {
        if let cache = pathsCache[fileURL] {
            return cache
        }
        
        guard let newURL = openFolderSelection(at: fileURL) else { return nil }
        pathsCache[fileURL] = newURL
        return newURL
    }
}
