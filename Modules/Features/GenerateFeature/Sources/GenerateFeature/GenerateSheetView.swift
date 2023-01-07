import SwiftUI

public struct GenerateSheetView: View {
    @StateObject var viewModel: GenerateSheetViewModel
    
    public init(fileURL: URL, onDismiss: @escaping () -> Void) {
        _viewModel = .init(wrappedValue: GenerateSheetViewModel(fileURL: fileURL, onDismiss: onDismiss))
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
                        Text(viewModel.modulesPathText)
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
                        Toggle("Skip this step", isOn: $viewModel.isSkipXcodeProjectOn)
                    }
                    HStack {
                        Text(viewModel.xcodeProjectPathText)
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
        .onAppear(perform: viewModel.onAppear)
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
            fileURL: URL(string: "path/to/modules.ash")!,
            onDismiss: {}
        )
    }
}
