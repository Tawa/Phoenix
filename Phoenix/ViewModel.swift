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

protocol ViewModelDataStore: AnyObject {
    var fileURL: URL? { get }
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
    @Published var showingGeneratePopover: Bool = false
    @Published var modulesFolderURL: URL? = nil {
        didSet {
            if let fileURL = fileURL, let modulesFolderURL = modulesFolderURL {
                modulesFolderURLCache[fileURL.path] = modulesFolderURL.path
            }
        }
    }
    @Published var xcodeProjectURL: URL? = nil {
        didSet {
            if let fileURL = fileURL, let xcodeProjectURL = xcodeProjectURL {
                xcodeProjectURLCache[fileURL.path] = xcodeProjectURL.path
            }
        }
    }
    
    private var modulesFolderURLCache: [String: String] {
        get {
            UserDefaults.standard.object(forKey: "modulesFolderURLCache") as? [String: String] ?? [String: String]()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "modulesFolderURLCache")
        }
    }

    private var xcodeProjectURLCache: [String: String] {
        get {
            UserDefaults.standard.object(forKey: "xcodeProjectURLCache") as? [String: String] ?? [String: String]()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "xcodeProjectURLCache")
        }
    }

    // MARK: - Filters
    @Published var componentsListFilter: String = ""
    
    weak var dataStore: ViewModelDataStore? {
        didSet {
            if let fileURL = dataStore?.fileURL {
//                modulesFolderURL = modulesFolderURLCache[fileURL.path].flatMap { URL(string: $0) }
//                xcodeProjectURL = xcodeProjectURLCache[fileURL.path].flatMap { URL(string: $0) }
            }
        }
    }
    private var fileURL: URL? { dataStore?.fileURL }
    
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
    
    private func getAccessToURL(file: Bool, completion: (URL) -> Void) {
        guard let fileURL = fileURL else {
            alertState = .errorString("File must be saved before packages can be generated.")
            return
        }
        if let url = openFolderSelection(at: fileURL, chooseFiles: file) {
            completion(url)
        }
    }
    
    func onOpenModulesFolder() {
        getAccessToURL(file: false) { url in
            self.modulesFolderURL = url
        }
    }
    
    func onOpenXcodeProject() {
        getAccessToURL(file: true) { url in
            self.xcodeProjectURL = url
        }
    }
    
    func onGeneratePopoverButton(fileURL: URL?) {
        if
            modulesFolderURL == nil,
            let fileURL = fileURL,
            FileManager.default.isDeletableFile(atPath: fileURL.path) {
            modulesFolderURL = fileURL
        }
        showingGeneratePopover = true
    }
    
    func onDismissGeneratePopover() {
        showingGeneratePopover = false
    }
    
    func onGeneratePopoverGenerate(document: PhoenixDocument) {
        onGenerate(document: document)
    }
    
    func onGenerate(document: PhoenixDocument) {
        guard let fileURL = modulesFolderURL else {
            alertState = .errorString("Could not find path for modules folder.")
            return
        }
        showingGeneratePopover = false
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
        let folderURL = fileURL
        for packageWithPath in packagesWithPath {
            let url = folderURL.appendingPathComponent(packageWithPath.path, isDirectory: true)
            do {
                try packagesGenerator.generate(package: packageWithPath.package, at: url)
            } catch {
                alertState = .errorString(error.localizedDescription)
            }
        }
        
        if let xcodeProjectURL = xcodeProjectURL {
            onSyncPBXProj(for: document, xcodeFileURL: xcodeProjectURL)
        } else {
            alertState = .errorString("Xcode Project not set")
        }
    }
    
    func onGenerateDemoProject(for component: Component, from document: PhoenixDocument, ashFileURL: URL?) {
        guard let ashFileURL = ashFileURL else {
            alertState = .errorString("File must be saved before packages can be generated.")
            return
        }
        
        guard
            let url = openFolderSelection(at: nil, chooseFiles: true)
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
    
    func onSyncPBXProj(for document: PhoenixDocument, xcodeFileURL: URL) {
        guard let ashFileURL = fileURL else {
            alertState = .errorString("File must be saved before packages can be generated.")
            return
        }
        
        let syncer = Container.pbxProjSyncer()
        do {
            try syncer.sync(document: document, at: ashFileURL, withProjectAt: xcodeFileURL)
        } catch {
            alertState = .errorString(error.localizedDescription)
        }
    }
    
    private func openFolderSelection(at fileURL: URL?, chooseFiles: Bool) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = fileURL?.deletingLastPathComponent()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = !chooseFiles
        openPanel.canChooseFiles = chooseFiles
        openPanel.canCreateDirectories = true
        openPanel.allowedContentTypes = []
        
        openPanel.runModal()
        return openPanel.url
    }
}
