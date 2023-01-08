import SwiftUI

struct AlertSheetModel: Identifiable {
    let id: String = UUID().uuidString
    let text: String
}

struct AlertSheet: View {
    let model: AlertSheetModel
    let onOkayButton: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Text(model.text)
                .font(.largeTitle)
            Button(action: onOkayButton) {
                Text("Ok")
            }.keyboardShortcut(.defaultAction)
        }
        .frame(maxWidth:  .infinity, maxHeight: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .onSubmit(onOkayButton)
    }
}

extension View {
    func alertSheet(model alertSheetModel: Binding<AlertSheetModel?>) -> some View {
        sheet(item: alertSheetModel) { model in
            AlertSheet(model: model) {
                alertSheetModel.wrappedValue = nil
            }
        }
    }
}

class GenerateFeatureViewModel: ObservableObject {
    @Published var generateFeatureInput: GenerateFeatureInput? = nil
    @Published var alert: AlertSheetModel? = nil
    
    func onGenerate(fileURL: URL?) {
        guard let fileURL else {
            alert = .init(text: "File should be saved first")
            return
        }
        generateFeatureInput = .init(fileURL: fileURL)
    }
    
    func isGenerateEnabled(fileURL: URL?) -> Bool {
        guard let fileURL else { return false }
        return true
    }
    
    //    func onGenerate(document: PhoenixDocument, fileURL: URL?) {
    //        getFileURL(fileURL: fileURL) { fileURL in
    //            self.onGenerate(document: document, nonOptionalFileURL: fileURL)
    //        }
    //    }
    //    func onGenerate(document: PhoenixDocument, nonOptionalFileURL: URL) {
    //        guard let modulesFolderURL = modulesFolderURL else {
    //            alertState = .errorString("Could not find path for modules folder.")
    //            return
    //        }
    //        generateFeatureInput = nil
    //        do {
    //            try projectGenerator.generate(document: document, folderURL: modulesFolderURL)
    //        } catch {
    //            alertState = .errorString("Error generating project: \(error)")
    //        }
    //
    //        guard !skipXcodeProject else { return }
    //        generateXcodeProject(for: document, fileURL: nonOptionalFileURL)
    //    }
    
    //    private func generateXcodeProject(for document: PhoenixDocument, fileURL: URL?) {
    //        guard let xcodeProjectURL = xcodeProjectURL else { return }
    //        onSyncPBXProj(for: document, xcodeFileURL: xcodeProjectURL, fileURL: fileURL)
    //    }
    
}

public struct GenerateFeatureView: View {
    @StateObject private var viewModel: GenerateFeatureViewModel = .init()
    let fileURL: URL?
    
    public init(fileURL: URL?) {
        self.fileURL = fileURL
    }
    
    public var body: some View {
        Button(action: { viewModel.onGenerate(fileURL: fileURL) }) {
            Image(systemName: "shippingbox.fill")
            Text("Generate")
        }
        .keyboardShortcut(.init("R"), modifiers: .command)
        .sheet(item: $viewModel.generateFeatureInput, content: { data in
            GenerateSheetView(fileURL: data.fileURL) {
                viewModel.generateFeatureInput = nil
            }
        })
        .alertSheet(model: $viewModel.alert)
        Button(action: { /*viewModel.onGenerate(document: document, fileURL: fileURL)*/ }) {
            Image(systemName: "play")
        }
        .disabled(!viewModel.isGenerateEnabled(fileURL: fileURL))
        .keyboardShortcut(.init("R"), modifiers: [.command, .shift])
    }
}

struct GenerateFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateFeatureView(fileURL: nil)
    }
}
