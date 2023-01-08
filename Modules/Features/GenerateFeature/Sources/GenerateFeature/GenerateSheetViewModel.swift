import Foundation

public struct GenerateSheetViewModel {
    let modulesPath: String
    let xcodeProjectPath: String
    
    let hasModulesPath: Bool
    let hasXcodeProjectPath: Bool
    let isSkipXcodeProjectOn: Bool

    let onOpenModulesFolder: () -> Void
    let onOpenXcodeProject: () -> Void
    let onSkipXcodeProject: (Bool) -> Void
    
    let onGenerate: () -> Void
    let onDismiss: () -> Void
    
    public init(
        modulesPath: String,
        xcodeProjectPath: String,
        hasModulesPath: Bool,
        hasXcodeProjectPath: Bool,
        isSkipXcodeProjectOn: Bool,
        onOpenModulesFolder: @escaping () -> Void,
        onOpenXcodeProject: @escaping () -> Void,
        onSkipXcodeProject: @escaping (Bool) -> Void,
        onGenerate: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.modulesPath = modulesPath
        self.xcodeProjectPath = xcodeProjectPath
        self.hasModulesPath = hasModulesPath
        self.hasXcodeProjectPath = hasXcodeProjectPath
        self.isSkipXcodeProjectOn = isSkipXcodeProjectOn
        self.onOpenModulesFolder = onOpenModulesFolder
        self.onOpenXcodeProject = onOpenXcodeProject
        self.onSkipXcodeProject = onSkipXcodeProject
        self.onGenerate = onGenerate
        self.onDismiss = onDismiss
    }
}
