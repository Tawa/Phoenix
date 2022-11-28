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

class ViewModel: ObservableObject {
    // MARK: - Selection
    var subscriptions: Set<AnyCancellable> = .init()
    let composition: Composition
    @Published var selectedComponentName: Name? = nil
    @Published var selectedFamilyName: String? = nil
    @Published var componentsListSections: [ComponentsListSection] = []
    
    // MARK: - Update Button
    private var appUpdateVersionInfoSub: AnyCancellable? = nil
    @Published var appUpdateVersionInfo: AppVersionInfo? = nil
    @Published var showingUpdatePopup: AppVersionInfo? = nil
    
    // MARK: - Sheets
    @Published var showingConfigurationPopup: Bool = false
    @Published var showingNewComponentPopup: ComponentPopupState? = nil
    @Published var showingDependencySheet: Bool = false
    @Published var showingRemoteDependencySheet: Bool = false
    @Published var alertState: AlertState? = nil
    @Published var showingGenerateSheet: Bool = false
    @Published var demoAppFeatureData: DemoAppFeatureInput? = nil
    @Published var modulesFolderURL: URL? = nil {
        didSet {
//            if let fileURL = fileURL, let modulesFolderURL = modulesFolderURL {
//                filesURLDataStore.set(modulesFolderURL: modulesFolderURL, forFileURL: fileURL)
//            }
        }
    }
    @Published var xcodeProjectURL: URL? = nil {
        didSet {
//            if let fileURL = fileURL, let xcodeProjectURL = xcodeProjectURL {
//                filesURLDataStore.set(xcodeProjectURL: xcodeProjectURL, forFileURL: fileURL)
//            }
        }
    }
    @Published var skipXcodeProject: Bool = false

    let appVersionUpdateProvider: AppVersionUpdateProviderProtocol
    let pbxProjSyncer: PBXProjectSyncerProtocol
    let filesURLDataStore: FilesURLDataStoreProtocol
    let projectGenerator: ProjectGeneratorProtocol
    
    
    // MARK: - Initialiser
    init(
        appVersionUpdateProvider: AppVersionUpdateProviderProtocol,
        pbxProjSyncer: PBXProjectSyncerProtocol,
        filesURLDataStore: FilesURLDataStoreProtocol,
        projectGenerator: ProjectGeneratorProtocol,
        composition: Composition
    ) {
        self.appVersionUpdateProvider = appVersionUpdateProvider
        self.pbxProjSyncer = pbxProjSyncer
        self.filesURLDataStore = filesURLDataStore
        self.projectGenerator = projectGenerator
        self.composition = composition

        subscribeToPublishers()
    }
        
    func onConfigurationButton() {
        showingConfigurationPopup = true
    }
    
    func onUpdateButton() {
        showingUpdatePopup = appUpdateVersionInfo
    }
    
    func onAddButton() {
        showingNewComponentPopup = .new
    }
    
    func onDuplicate(component: Component) {
        showingNewComponentPopup = .template(component)
    }
    
    private func getFileURL(fileURL: URL?, _ completion: @escaping (URL) -> Void) {
        guard let fileURL = fileURL else {
            alertState = .errorString("File must be saved before packages can be generated.")
            return
        }
        completion(fileURL)
    }
    
    private func getAccessToURL(file: Bool, fileURL: URL?, completion: @escaping (URL) -> Void) {
        getFileURL(fileURL: fileURL) { fileURL in
            if let url = self.openFolderSelection(at: fileURL, chooseFiles: file) {
                completion(url)
            }
        }
    }
    
    func onOpenModulesFolder(fileURL: URL?) {
        getAccessToURL(file: false, fileURL: fileURL) { url in
            if url.lastPathComponent.hasSuffix(".ash") {
                self.modulesFolderURL = url.deletingLastPathComponent()
            } else {
                self.modulesFolderURL = url
            }
        }
    }
    
    func onOpenXcodeProject(fileURL: URL?) {
        getAccessToURL(file: true, fileURL: fileURL) { url in
            self.xcodeProjectURL = url
        }
    }
    
    func onSkipXcodeProject(_ skip: Bool) {
        skipXcodeProject = skip
    }
    
    func onGenerateSheetButton(fileURL: URL?) {
        getFileURL(fileURL: fileURL) { fileURL in
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
    
    func onGenerate(document: PhoenixDocument, fileURL: URL?) {
        getFileURL(fileURL: fileURL) { fileURL in
            self.onGenerate(document: document, nonOptionalFileURL: fileURL)
        }
    }
    func onGenerate(document: PhoenixDocument, nonOptionalFileURL: URL) {
        guard let modulesFolderURL = modulesFolderURL else {
            alertState = .errorString("Could not find path for modules folder.")
            return
        }
        showingGenerateSheet = false
        do {
            try projectGenerator.generate(document: document, folderURL: modulesFolderURL)
        } catch {
            alertState = .errorString("Error generating project: \(error)")
        }
        
        guard !skipXcodeProject else { return }
        generateXcodeProject(for: document, fileURL: nonOptionalFileURL)
    }

    private func generateXcodeProject(for document: PhoenixDocument, fileURL: URL?) {
        guard let xcodeProjectURL = xcodeProjectURL else { return }
        onSyncPBXProj(for: document, xcodeFileURL: xcodeProjectURL, fileURL: fileURL)
    }
    
    func onGenerateDemoProject(for component: Component, from document: PhoenixDocument, fileURL: URL?) {
        if let fileURL = fileURL {
            modulesFolderURL = filesURLDataStore.getModulesFolderURL(forFileURL: fileURL).flatMap { url in
                guard (try? FileManager.default.contentsOfDirectory(atPath: url.path)) != nil else { return nil }
                return url
            }
            xcodeProjectURL = filesURLDataStore.getXcodeProjectURL(forFileURL: fileURL).flatMap { url in
                guard (try? FileManager.default.contentsOfDirectory(atPath: url.path)) != nil else { return nil }
                return url
            }
        }

        getFileURL(fileURL: fileURL) { fileURL in
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
    
    func onSyncPBXProj(for document: PhoenixDocument, xcodeFileURL: URL, fileURL: URL?) {
        getFileURL(fileURL: fileURL) { fileURL in
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
            .sink { _ in
            } receiveValue: { appVersionInfos in
                self.appUpdateVersionInfo = appVersionInfos.results.first
            }
    }
}

// MARK: - Private
private extension ViewModel {
    func subscribeToPublishers() {
        composition
            .selectionRepository()
            .selectionPathPublisher
            .sink { [weak self] selectionPath in
                self?.selectedComponentName = self?.composition.getSelectedComponentUseCase().binding.wrappedValue.name
            }.store(in: &subscriptions)
        
        composition
            .selectionRepository()
            .familyNamePublisher
            .sink { [weak self] familyName in
                guard self?.selectedFamilyName != familyName else { return }
                self?.selectedFamilyName = familyName
            }.store(in: &subscriptions)
        
        _selectedFamilyName
            .projectedValue
            .sink { [weak self] familyName in
                guard let selectionRepository = self?.composition.selectionRepository(),
                      selectionRepository.familyName != familyName
                else { return }
                if let familyName = familyName {
                    selectionRepository.select(familyName: familyName)
                } else {
                    selectionRepository.deselectFamilyName()
                }
            }.store(in: &subscriptions)
        
        composition
            .getComponentsListItemsUseCase()
            .listPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                self?.componentsListSections = sections
            }.store(in: &subscriptions)
    }
}
