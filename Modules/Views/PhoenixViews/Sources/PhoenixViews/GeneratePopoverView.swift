import SwiftUI

public struct GeneratePopoverViewModel {
    let modulesPath: String
    let xcodeProjectPath: String
    
    let onOpenModulesFolder: () -> Void
    let onOpenXcodeProject: () -> Void
    
    let onGenerate: () -> Void
    let onDismiss: () -> Void
    
    public init(
        modulesPath: String,
        xcodeProjectPath: String,
        onOpenModulesFolder: @escaping () -> Void,
        onOpenXcodeProject: @escaping () -> Void,
        onGenerate: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.modulesPath = modulesPath
        self.xcodeProjectPath = xcodeProjectPath
        self.onOpenModulesFolder = onOpenModulesFolder
        self.onOpenXcodeProject = onOpenXcodeProject
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
                        .opacity(0.8)
                    Spacer()
                }
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Button(action: viewModel.onOpenXcodeProject, label: {
                        Image(systemName: "wrench.and.screwdriver")
                    }).help("Open Xcode Project")
                    Text("Xcode Project")
                }
                HStack {
                    Text(viewModel.xcodeProjectPath)
                        .opacity(0.8)
                    Spacer()
                }
            }
            
            HStack {
                Button(action: viewModel.onGenerate) {
                    Text("Generate")
                }
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
}

struct GeneratePopoverView_Previews: PreviewProvider {
    static var previews: some View {
        GeneratePopoverView(
            viewModel: GeneratePopoverViewModel(
                modulesPath: "path/to/modules",
                xcodeProjectPath: "path/to/Project.xcodeproj",
                onOpenModulesFolder: {},
                onOpenXcodeProject: {},
                onGenerate: {},
                onDismiss: {}
            )
        )
    }
}
