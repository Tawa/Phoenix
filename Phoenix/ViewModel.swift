import AppVersionProviderContract
import Combine
import Component
import ComponentDetailsProviderContract
import DemoAppFeature
import DemoAppGeneratorContract
import PackageGeneratorContract
import PBXProjectSyncerContract
import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage
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
    
    // MARK: - Sheets
    @Published var showingConfigurationPopup: Bool = false
    @Published var showingNewComponentPopup: ComponentPopupState? = nil
    @Published var showingDependencySheet: Bool = false
    @Published var alertState: AlertState? = nil
    @Published var showingGenerateSheet: Bool = false
    @Published var demoAppFeatureData: DemoAppFeatureInput? = nil
    @Published var modulesFolderURL: URL? = nil {
        didSet {
            if let fileURL = fileURL, let modulesFolderURL = modulesFolderURL {
                filesURLDataStore.set(modulesFolderURL: modulesFolderURL, forFileURL: fileURL)
            }
        }
    }
    @Published var xcodeProjectURL: URL? = nil {
        didSet {
            if let fileURL = fileURL, let xcodeProjectURL = xcodeProjectURL {
                filesURLDataStore.set(xcodeProjectURL: xcodeProjectURL, forFileURL: fileURL)
            }
        }
    }
    @Published var skipXcodeProject: Bool = false

    // MARK: - Filters
    @Published var componentsListFilter: String = ""
    
    weak var dataStore: ViewModelDataStore? {
        didSet {
            if let fileURL = dataStore?.fileURL {
                modulesFolderURL = filesURLDataStore.getModulesFolderURL(forFileURL: fileURL).flatMap { url in
                    guard (try? FileManager.default.contentsOfDirectory(atPath: url.path)) != nil else { return nil }
                    return url
                }
                xcodeProjectURL = filesURLDataStore.getXcodeProjectURL(forFileURL: fileURL).flatMap { url in
                    guard (try? FileManager.default.contentsOfDirectory(atPath: url.path)) != nil else { return nil }
                    return url
                }
            }
        }
    }
    private var fileURL: URL? { dataStore?.fileURL }
    
    let appVersionUpdateProvider: AppVersionUpdateProviderProtocol
    let pbxProjSyncer: PBXProjectSyncerProtocol
    let familyFolderNameProvider: FamilyFolderNameProviderProtocol
    let filesURLDataStore: FilesURLDataStoreProtocol
    let projectGenerator: ProjectGeneratorProtocol
    
    
    // MARK: - Initialiser
    init(
        appVersionUpdateProvider: AppVersionUpdateProviderProtocol,
        pbxProjSyncer: PBXProjectSyncerProtocol,
        familyFolderNameProvider: FamilyFolderNameProviderProtocol,
        filesURLDataStore: FilesURLDataStoreProtocol,
        projectGenerator: ProjectGeneratorProtocol
    ) {
        self.appVersionUpdateProvider = appVersionUpdateProvider
        self.pbxProjSyncer = pbxProjSyncer
        self.familyFolderNameProvider = familyFolderNameProvider
        self.filesURLDataStore = filesURLDataStore
        self.projectGenerator = projectGenerator
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
    
    private func getFileURL(_ completion: @escaping (URL) -> Void) {
        guard let fileURL = fileURL else {
            alertState = .errorString("File must be saved before packages can be generated.")
            return
        }
        completion(fileURL)
    }
    
    private func getAccessToURL(file: Bool, completion: @escaping (URL) -> Void) {
        getFileURL { fileURL in
            if let url = self.openFolderSelection(at: fileURL, chooseFiles: file) {
                completion(url)
            }
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
    
    func onGenerateSheetButton() {
        getFileURL { fileURL in
            if self.modulesFolderURL == nil,
               FileManager.default.isDeletableFile(atPath: fileURL.path) {
                self.modulesFolderURL = fileURL.deletingLastPathComponent()
            }
            self.showingGenerateSheet = true
        }
    }
    
    func onDismissGenerateSheet() {
        showingGenerateSheet = false
    }
    
    func onGenerateSheetGenerate(document: PhoenixDocument) {
        onGenerate(document: document)
    }
    
    func onGenerate(document: PhoenixDocument) {
        guard let fileURL = modulesFolderURL else {
            alertState = .errorString("Could not find path for modules folder.")
            return
        }
        showingGenerateSheet = false
        do {
            try projectGenerator.generate(document: document, folderURL: fileURL)
        } catch {
            alertState = .errorString("Error generating project: \(error)")
        }
        
        guard !skipXcodeProject else { return }
        generateXcodeProject(for: document)
    }
    
    private func generateXcodeProject(for document: PhoenixDocument) {
        guard let xcodeProjectURL = xcodeProjectURL else { return }
        onSyncPBXProj(for: document, xcodeFileURL: xcodeProjectURL)
    }
    
    func onGenerateDemoProject(for component: Component, from document: PhoenixDocument, ashFileURL: URL?) {
        getFileURL { fileURL in
            self.demoAppFeatureData = .init(
                component: component,
                document: document,
                ashFileURL: fileURL,
                onDismiss: { [weak self] in
                    self?.demoAppFeatureData = nil
                },
                onError: { error in
                    self.alertState = .errorString(error.localizedDescription)
                })
        }
    }
    
    func onSyncPBXProj(for document: PhoenixDocument, xcodeFileURL: URL) {
        getFileURL { fileURL in
            do {
                try self.pbxProjSyncer.sync(document: document, at: fileURL, withProjectAt: xcodeFileURL)
            } catch {
                self.alertState = .errorString(error.localizedDescription)
            }
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
        appUpdateVersionInfoSub = appVersionUpdateProvider
            .appVersionsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
            } receiveValue: { appVersionInfos in
                withAnimation {
                    self.appUpdateVersionInfo = appVersionInfos.results.first
                }
            }
    }
}
