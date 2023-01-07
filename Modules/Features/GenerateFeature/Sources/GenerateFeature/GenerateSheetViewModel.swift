import SwiftUI
import Foundation

public class GenerateSheetViewModel: ObservableObject {
    let fileURL: URL
    let onDismiss: () -> Void

    // MARK: - Paths
    @Published private(set) var modulesURL: URL? = nil {
        didSet {
            guard let modulesURL else { return }
            dataStore.set(modulesFolderURL: modulesURL, forFileURL: fileURL)
        }
    }
    @Published private(set) var xcodeProjectURL: URL? = nil {
        didSet {
            guard let xcodeProjectURL else { return }
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
            dataStore.set(shouldSkipXcodeProject: isSkipXcodeProjectOn, forFileURL: fileURL)
        }
    }
    var isGenerateEnabled: Bool {
        guard
            hasModulesPath,
            hasXcodeProjectPath || isSkipXcodeProjectOn
        else { return false }
        return true
    }
    
    // File URLs Managers
    var ashFileURLGetter: LocalFileURLGetter
    var xcodeProjURLGetter: LocalFileURLGetter
    var dataStore: GenerateFeatureDataStoreProtocol
    var fileAccessValidator: FileAccessValidatorProtocol
    
    func onOpenModulesFolder() {
        ashFileURLGetter.getUrl().map { modulesURL = $0 }
    }
    
    func onOpenXcodeProject() {
        xcodeProjURLGetter.getUrl().map { xcodeProjectURL = $0 }
    }
    
    func onGenerate() {
        
    }
    
    func onAppear() {
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
    
    public init(
        fileURL: URL,
        onDismiss: @escaping () -> Void
    ) {
        self.fileURL = fileURL
        self.onDismiss = onDismiss

        ashFileURLGetter = AshFileURLGetter(fileURL: fileURL)
        xcodeProjURLGetter = XcodeProjURLGetter(fileURL: fileURL)
        dataStore = GenerateFeatureDataStore(dictionaryCache: UserDefaults.standard)
        fileAccessValidator = FileAccessValidator()
    }
}
