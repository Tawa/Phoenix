import AppVersionProviderContract
import Combine
import ComponentPackagesProviderContract
import DemoAppFeature
import DemoAppGeneratorContract
import Factory
import Package
import PackageGeneratorContract
import PBXProjectSyncerContract
import PhoenixDocument
import ProjectGeneratorContract
import SwiftUI
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
    
    // MARK: - Update Button
    private var appUpdateVersionInfoSub: AnyCancellable? = nil
    @Published var appUpdateVersionInfo: AppVersionInfo? = nil
    
    // MARK: - Popovers
    @Published var showingConfigurationPopup: Bool = false
    @Published var showingNewComponentPopup: ComponentPopupState? = nil
    @Published var showingDependencyPopover: Bool = false
    @Published var alertState: AlertState? = nil
    @Published var showingGeneratePopover: Bool = false
    @Published var demoAppFeatureData: DemoAppFeatureInput? = nil
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
    @Published var skipXcodeProject: Bool = false
    
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
                modulesFolderURL = modulesFolderURLCache[fileURL.path].flatMap {
                    guard (try? FileManager.default.contentsOfDirectory(atPath: $0)) != nil else { return nil }
                    return URL(string: $0)
                }
                xcodeProjectURL = xcodeProjectURLCache[fileURL.path].flatMap {
                    guard (try? FileManager.default.contentsOfDirectory(atPath: $0)) != nil else { return nil }
                    return URL(string: $0)
                }
            }
        }
    }
    private var fileURL: URL? { dataStore?.fileURL }
    
    private var pathsCache: [URL: URL] = [:]
    
    let projectGenerator: ProjectGeneratorProtocol
    let familyFolderNameProvider: FamilyFolderNameProviderProtocol
    
    // MARK: - Initialiser
    init(
        projectGenerator: ProjectGeneratorProtocol,
        familyFolderNameProvider: FamilyFolderNameProviderProtocol
    ) {
        self.projectGenerator = projectGenerator
        self.familyFolderNameProvider = familyFolderNameProvider
    }
    
    // MARK: - FamilyFolderNameProvider
    func folderName(forFamily family: String) -> String {
        familyFolderNameProvider.folderName(forFamily: family)
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
            if url.lastPathComponent.hasSuffix(".ash") {
                self.modulesFolderURL = url.deletingLastPathComponent()
            } else {
                self.modulesFolderURL = url
            }
        }
    }
    
    func onOpenXcodeProject() {
        getAccessToURL(file: true) { url in
            self.xcodeProjectURL = url
        }
    }
    
    func onSkipXcodeProject(_ skip: Bool) {
        skipXcodeProject = skip
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
        let projectGenerator = Container.projectGenerator()
        do {
            try projectGenerator.generate(document: document, folderURL: fileURL)
        } catch {
            alertState = .errorString("Error generator project: \(error)")
        }
        
        guard !skipXcodeProject else { return }
        generateXcodeProject(for: document)
    }
    
    private func generateXcodeProject(for document: PhoenixDocument) {
        guard !skipXcodeProject else { return }
        if let xcodeProjectURL = xcodeProjectURL {
            onSyncPBXProj(for: document, xcodeFileURL: xcodeProjectURL)
        }
    }
    
    func onGenerateDemoProject(for component: Component, from document: PhoenixDocument, ashFileURL: URL?) {
        guard let ashFileURL = ashFileURL else {
            alertState = .errorString("File must be saved before packages can be generated.")
            return
        }
        demoAppFeatureData = .init(
            component: component,
            document: document,
            ashFileURL: ashFileURL,
            onDismiss: { [weak self] in
                self?.demoAppFeatureData = nil
            })
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
    
    func checkForUpdate() {
        let appVersionUpdateProvider = Container.appVersionUpdateProvider()
        
        appUpdateVersionInfoSub = appVersionUpdateProvider
            .appVersionsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
            } receiveValue: { appVersionInfos in
                withAnimation {
                    self.appUpdateVersionInfo = appVersionInfos.first
                }
            }
    }
}
