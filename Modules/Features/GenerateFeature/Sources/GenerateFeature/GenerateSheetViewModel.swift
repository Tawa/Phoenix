import SwiftUI
import Foundation

public class GenerateSheetViewModel: ObservableObject {
    let fileURL: URL
    let onDismiss: () -> Void

    // MARK: - Paths
    @Published private(set) var modulesURL: URL? = nil
    @Published private(set) var xcodeProjectURL: URL? = nil
    
    let modulesPathPlaceholder: String = "path/to/modules"
    let xcodeProjectPathPlaceholder: String = "path/to/Project.xcodeproj"
    
    var modulesPathText: String { modulesURL?.path ?? modulesPathPlaceholder }
    var xcodeProjectPathText: String { xcodeProjectURL?.path ?? xcodeProjectPathPlaceholder }
    
    var hasModulesPath: Bool { modulesURL != nil }
    var hasXcodeProjectPath: Bool { xcodeProjectURL != nil }
    
    // MARK: - Generate
    @Published var isSkipXcodeProjectOn: Bool = false
    var isGenerateEnabled: Bool {
        guard
            hasModulesPath,
            hasXcodeProjectPath || isSkipXcodeProjectOn
        else { return false }
        return true
    }
    
    // MARK: - Private
    var ashFileURLGetter: LocalFileURLGetter
    var xcodeProjURLGetter: LocalFileURLGetter
    
    func onOpenModulesFolder() {
        ashFileURLGetter.getUrl().map { modulesURL = $0 }
    }
    
    func onOpenXcodeProject() {
        xcodeProjURLGetter.getUrl().map { xcodeProjectURL = $0 }
    }
    
    func onSkipXcodeProject() {
        
    }
    
    func onGenerate() {
        
    }
    
    public init(
        fileURL: URL,
        onDismiss: @escaping () -> Void
    ) {
        self.fileURL = fileURL
        self.onDismiss = onDismiss

        ashFileURLGetter = AshFileURLGetter(fileURL: fileURL)
        xcodeProjURLGetter = XcodeProjURLGetter(fileURL: fileURL)
    }
}
