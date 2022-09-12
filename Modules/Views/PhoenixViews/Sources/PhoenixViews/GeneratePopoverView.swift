import SwiftUI

public struct GeneratePopoverViewModel {
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

public struct GeneratePopoverView: View {
    let viewModel: GeneratePopoverViewModel
    
    public init(viewModel: GeneratePopoverViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: viewModel.onOpenModulesFolder, label: {
                        Image(systemName: "folder")
                    }).help("Open Folder")
                    Text("Modules Folder")
                }
                HStack {
                    Text(viewModel.modulesPath)
                        .opacity(viewModel.hasModulesPath ? 1 : 0.2)
                    Spacer()
                }
            }.onTapGesture(perform: viewModel.onOpenModulesFolder)
            
            VStack(alignment: .leading) {
                HStack {
                    Button(action: viewModel.onOpenXcodeProject, label: {
                        Image(systemName: "wrench.and.screwdriver")
                    }).help("Open Xcode Project")
                    Text("Xcode Project")
                    Toggle("Skip this step", isOn: Binding(get: {
                        viewModel.isSkipXcodeProjectOn
                    }, set: { newValue in
                        self.viewModel.onSkipXcodeProject(newValue)
                    }))
                }
                HStack {
                    Text(viewModel.xcodeProjectPath)
                        .opacity(xcodeProjectPathOpaticy)
                    Spacer()
                }
            }.onTapGesture(perform: viewModel.onOpenXcodeProject)
                        
            HStack {
                Button(action: viewModel.onGenerate) {
                    Text("Generate")
                }.disabled(!isGenerateEnabled)
                Button(action: viewModel.onDismiss) {
                    Text("Cancel")
                }
            }
            
            Spacer()
        }
        .padding()
        .onExitCommand(perform: viewModel.onDismiss)
        .frame(minWidth: 500)
    }
    
    private var isGenerateEnabled: Bool {
        guard viewModel.hasModulesPath else { return false }
        if viewModel.hasXcodeProjectPath { return true }
        guard viewModel.isSkipXcodeProjectOn else { return false }
        return true
    }
    
    private var xcodeProjectPathOpaticy: Double {
        if viewModel.isSkipXcodeProjectOn {
            return 0.2
        }
        return viewModel.hasXcodeProjectPath ? 1 : 0.2
    }
}

struct GeneratePopoverView_Previews: PreviewProvider {
    static var previews: some View {
        GeneratePopoverView(
            viewModel: GeneratePopoverViewModel(
                modulesPath: "path/to/modules",
                xcodeProjectPath: "path/to/Project.xcodeproj",
                hasModulesPath: true,
                hasXcodeProjectPath: false,
                isSkipXcodeProjectOn: false,
                onOpenModulesFolder: {},
                onOpenXcodeProject: {},
                onSkipXcodeProject: { _ in },
                onGenerate: {},
                onDismiss: {}
            )
        )
    }
}
