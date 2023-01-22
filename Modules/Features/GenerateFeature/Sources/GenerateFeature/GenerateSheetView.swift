import SwiftUI

struct GenerateSheetView: View {
    let viewModel: GenerateSheetViewModel
    
    init(viewModel: GenerateSheetViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Button(action: viewModel.onOpenModulesFolder) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "folder")
                        Text("Modules Folder")
                    }
                    HStack {
                        Text(viewModel.modulesPath)
                            .opacity(viewModel.hasModulesPath ? 1 : 0.2)
                        Spacer()
                    }
                }
            }.buttonStyle(.plain)
            
            Button(action: viewModel.onOpenXcodeProject) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver")
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
                }
            }.buttonStyle(.plain)

            HStack {
                Button(action: viewModel.onGenerate) {
                    Text("Generate")
                }.disabled(!isGenerateEnabled)
                    .keyboardShortcut(.defaultAction)
                Button(action: viewModel.onDismiss) {
                    Text("Cancel")
                }.keyboardShortcut(.cancelAction)
            }
            
            Spacer()
        }
        .padding()
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

struct GenerateSheetView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateSheetView(
            viewModel: GenerateSheetViewModel(
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
