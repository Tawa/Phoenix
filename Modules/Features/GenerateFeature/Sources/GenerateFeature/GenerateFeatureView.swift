import AccessibilityIdentifiers
import GenerateFeatureDataStoreContract
import LocalFileURLProviderContract
import PBXProjectSyncerContract
import PhoenixDocument
import ProjectGeneratorContract
import SwiftUI

public struct GenerateFeatureDependencies {
    let ashFileURLProvider: LocalFileURLProviderProtocol
    let dataStore: GenerateFeatureDataStoreProtocol
    let projectGenerator: ProjectGeneratorProtocol
    let pbxProjectSyncer: PBXProjectSyncerProtocol
    let xcodeProjURLProvider: LocalFileURLProviderProtocol
    
    public init(
        ashFileURLProvider: LocalFileURLProviderProtocol,
        dataStore: GenerateFeatureDataStoreProtocol,
        projectGenerator: ProjectGeneratorProtocol,
        pbxProjectSyncer: PBXProjectSyncerProtocol,
        xcodeProjURLProvider: LocalFileURLProviderProtocol
    ) {
        self.ashFileURLProvider = ashFileURLProvider
        self.dataStore = dataStore
        self.projectGenerator = projectGenerator
        self.pbxProjectSyncer = pbxProjectSyncer
        self.xcodeProjURLProvider = xcodeProjURLProvider
    }
}

final class GenerateFeatureViewModel: ObservableObject {
    @Published var generateFeatureInput: GenerateFeatureInput? = nil
    let fileURL: URL?
    let onGenerate: () -> Void
    let onAlert: (String) -> Void
    
    let projectGenerator: ProjectGeneratorProtocol
    let pbxProjectSyncer: PBXProjectSyncerProtocol
    
    // MARK: - Paths
    @Published private(set) var modulesURL: URL? = nil {
        didSet {
            guard let fileURL, let modulesURL else { return }
            dataStore.set(modulesFolderURL: modulesURL, forFileURL: fileURL)
        }
    }
    @Published private(set) var xcodeProjectURL: URL? = nil {
        didSet {
            guard let fileURL, let xcodeProjectURL else { return }
            dataStore.set(xcodeProjectURL: xcodeProjectURL, forFileURL: fileURL)
        }
    }
    
    let modulesPathPlaceholder: String = "path/to/modules"
    let xcodeProjectPathPlaceholder: String = "path/to/Project.xcodeproj"
    
    var modulesPathText: String { modulesURL?.path ?? modulesPathPlaceholder }
    var xcodeProjectPathText: String { xcodeProjectURL?.path ?? xcodeProjectPathPlaceholder }
    
    var hasModulesPath: Bool { modulesURL != nil }
    var hasXcodeProjectPath: Bool { xcodeProjectURL != nil }
    
    // MARK: - Generate
    @Published var isSkipXcodeProjectOn: Bool = false {
        didSet {
            guard let fileURL else { return }
            dataStore.set(shouldSkipXcodeProject: isSkipXcodeProjectOn, forFileURL: fileURL)
        }
    }
    var isGenerateEnabled: Bool {
        guard
            fileURL != nil,
            hasModulesPath,
            hasXcodeProjectPath || isSkipXcodeProjectOn
        else { return false }
        return true
    }
    
    // File URLs Managers
    var ashFileURLProvider: LocalFileURLProviderProtocol
    var xcodeProjURLProvider: LocalFileURLProviderProtocol
    var dataStore: GenerateFeatureDataStoreProtocol
    var fileAccessValidator: FileAccessValidatorProtocol
    
    public init(fileURL: URL?,
                onGenerate: @escaping () -> Void,
                onAlert: @escaping (String) -> Void,
                dependencies: GenerateFeatureDependencies) {
        self.fileURL = fileURL
        self.onGenerate = onGenerate
        self.onAlert = onAlert
        
        ashFileURLProvider = dependencies.ashFileURLProvider
        xcodeProjURLProvider = dependencies.xcodeProjURLProvider
        fileAccessValidator = FileAccessValidator()
        
        dataStore = dependencies.dataStore
        projectGenerator = dependencies.projectGenerator
        pbxProjectSyncer = dependencies.pbxProjectSyncer
        
        guard let fileURL else { return }
        dataStore.getModulesFolderURL(forFileURL: fileURL)
            .map {
                guard fileAccessValidator.hasAccess(to: $0) else { return }
                modulesURL = $0
            }
        dataStore.getXcodeProjectURL(forFileURL: fileURL)
            .map {
                guard fileAccessValidator.hasAccess(to: $0) else { return }
                xcodeProjectURL = $0
            }
        isSkipXcodeProjectOn = dataStore.getShouldSkipXcodeProject(forFileURL: fileURL)
    }
    
    func onOpenModulesFolder() {
        ashFileURLProvider.localFileURL().map { modulesURL = $0 }
    }
    
    func onOpenXcodeProject() {
        xcodeProjURLProvider.localFileURL().map { xcodeProjectURL = $0 }
    }
    
    func onSkipXcodeProject(_ value: Bool) {
        isSkipXcodeProjectOn = value
    }
    
    func onGenerate(document: PhoenixDocument) {
        getFileURL { fileURL in
            self.onGenerate(document: document, fileURL: fileURL)
        }
    }
    
    func onGenerateSheet() {
        getFileURL { fileURL in
            self.generateFeatureInput = .init(fileURL: fileURL)
        }
    }
    
    // MARK: - Private
    private func getFileURL(_ completion: (URL) -> Void) {
        guard let fileURL else {
            onAlert("File should be saved first")
            return
        }
        completion(fileURL)
    }
    
    private func onGenerate(document: PhoenixDocument, fileURL: URL) {
        let generationStart: Date = .now
        guard let modulesURL = modulesURL else {
            onAlert("Could not find path for modules folder.")
            generateFeatureInput = nil
            return
        }
        do {
            try projectGenerator.generate(document: document, folderURL: modulesURL)
            if !isSkipXcodeProjectOn {
                try generateXcodeProject(for: document, fileURL: fileURL)
            }
            let packagesCount = document.families.flatMap(\.components).flatMap(\.modules.keys).count
            let macrosCount = document.macroComponents.count
            let count = packagesCount + macrosCount
            displaySuccessMessage(
                count: count,
                duration: generationStart.distance(to: Date())
            )
        } catch {
            onAlert("Error generating project: \(error)")
        }
        generateFeatureInput = nil
        onGenerate()
    }
    
    private func generateXcodeProject(for document: PhoenixDocument, fileURL: URL) throws {
        guard let xcodeProjectURL = xcodeProjectURL else {
            onAlert("Xcode Project URL missing")
            generateFeatureInput = nil
            return
        }
        try onSyncPBXProj(for: document, xcodeFileURL: xcodeProjectURL, fileURL: fileURL)
    }
    
    private func onSyncPBXProj(for document: PhoenixDocument, xcodeFileURL: URL, fileURL: URL) throws {
        try pbxProjectSyncer.sync(document: document, at: fileURL, withProjectAt: xcodeFileURL)
    }
    
    private func displaySuccessMessage(count: Int, duration: TimeInterval) {
        var successMessage: String = "Success"
        successMessage += "\n"
        successMessage += "Generated \(count) \(count == 1 ? "package" : "packages")"
        let deltaTime = round(1000 * duration) / 1000
        successMessage += " in \(deltaTime) seconds"
        onAlert(successMessage)
    }
}

public struct GenerateFeatureView: View {
    @ObservedObject private var viewModel: GenerateFeatureViewModel
    let getDocument: () -> PhoenixDocument
    
    public init(
        fileURL: URL?,
        getDocument: @escaping @autoclosure () -> PhoenixDocument,
        onGenerate: @escaping () -> Void,
        onAlert: @escaping (String) -> Void,
        dependencies: GenerateFeatureDependencies
    ) {
        self._viewModel = .init(wrappedValue: .init(
            fileURL: fileURL,
            onGenerate: onGenerate,
            onAlert: onAlert,
            dependencies: dependencies
        ))
        self.getDocument = getDocument
    }
    
    public var body: some View {
        Button(action: viewModel.onGenerateSheet) {
            Image(systemName: "shippingbox.fill")
            Text("Generate")
        }
        .keyboardShortcut(.init("R"), modifiers: .command)
        .sheet(item: $viewModel.generateFeatureInput, content: { data in
            GenerateSheetView(
                viewModel: .init(
                    modulesPath: viewModel.modulesPathText,
                    xcodeProjectPath: viewModel.xcodeProjectPathText,
                    hasModulesPath: viewModel.hasModulesPath,
                    hasXcodeProjectPath: viewModel.hasXcodeProjectPath,
                    isSkipXcodeProjectOn: viewModel.isSkipXcodeProjectOn,
                    onOpenModulesFolder: viewModel.onOpenModulesFolder,
                    onOpenXcodeProject: viewModel.onOpenXcodeProject,
                    onSkipXcodeProject: viewModel.onSkipXcodeProject,
                    onGenerate: onGenerate,
                    onDismiss: { viewModel.generateFeatureInput = nil }
                )
            )
        })
        Button(action: onGenerate) {
            Image(systemName: "play")
        }
        .disabled(!viewModel.isGenerateEnabled)
        .keyboardShortcut(.init("R"), modifiers: [.command, .shift])
    }
    
    // MARK: - Private
    private func onGenerate() {
        viewModel.onGenerate(document: getDocument())
    }
}
