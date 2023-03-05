import GenerateFeatureDataStoreContract
import PhoenixDocument
import ProjectValidatorContract
import SwiftUI

struct ValidationPopover: Identifiable {
    let id: String = UUID().uuidString
    let text: String
}

enum ValidationState {
    case loading
    case warning(String)
    case error(String)
    case valid
}

final class ValidationFeatureViewModel: ObservableObject {
    let document: PhoenixDocument
    let fileURL: URL?
    let dataStore: GenerateFeatureDataStoreProtocol
    let projectValidator: ProjectValidatorProtocol
   
    @Published var state: ValidationState = .loading
    @Published var presentedPopover: ValidationPopover?
    private var popoverText: String? {
        switch state {
        case .loading:
            return ""
        case .warning(let string):
            return string
        case .error(let string):
            return string
        case .valid:
            return ""
        }
    }
    
    init(
        document: PhoenixDocument,
        fileURL: URL?,
        dataStore: GenerateFeatureDataStoreProtocol,
        projectValidator: ProjectValidatorProtocol
    ) {
        self.document = document
        self.fileURL = fileURL
        self.dataStore = dataStore
        self.projectValidator = projectValidator
        
        validate()
    }
    
    @MainActor
    private func update(state: ValidationState) {
        self.state = state
    }
    
    private func validate() {
        guard let fileURL
        else {
            Task {
                await update(state: .error("Unsaved File"))
            }
            return
        }
        
        guard let modulesFolderURL = dataStore.getModulesFolderURL(forFileURL: fileURL)
        else {
            Task {
                await update(state: .error("Missing Modules Folder URL"))
            }
            return
        }
        Task {
            await update(state: .loading)
            do {
                try await validateProject(
                    document: document,
                    fileURL: fileURL,
                    modulesFolderURL: modulesFolderURL
                )
                await update(state: .valid)
            } catch ProjectValidatorError.accessIsNotGranted {
                await update(state: .error("Access to modules folder is not granted"))
            } catch ProjectValidatorError.missingFiles {
                await update(state: .error("Could not read local file"))
            } catch ProjectValidatorError.unsavedChanges {
                await update(state: .error("Unsaved Changes"))
            } catch PackagesValidatorError.projectOutOfSync(let warningText) {
                await update(state: .warning(warningText))
            } catch {
                await update(state: .error("\(error)"))
            }
        }
    }
    
    private func validateProject(
        document: PhoenixDocument,
        fileURL: URL,
        modulesFolderURL: URL
    ) async throws {
        try await projectValidator.validate(
            document: document,
            fileURL: fileURL,
            modulesFolderURL: modulesFolderURL
        )
    }
    
    func onTap() {
        guard let popoverText else { return }
        self.presentedPopover = .init(text: popoverText)
    }
}

public struct ValidationFeatureDependencies {
    let dataStore: GenerateFeatureDataStoreProtocol
    let projectValidator: ProjectValidatorProtocol
    
    public init(dataStore: GenerateFeatureDataStoreProtocol,
                projectValidator: ProjectValidatorProtocol) {
        self.dataStore = dataStore
        self.projectValidator = projectValidator
    }
}

public struct ValidationFeatureView: View {
    @ObservedObject var viewModel: ValidationFeatureViewModel
    
    public init(
        document: PhoenixDocument,
        fileURL: URL?,
        dependencies: ValidationFeatureDependencies
    ) {
        _viewModel = .init(
            initialValue: ValidationFeatureViewModel(
                document: document,
                fileURL: fileURL,
                dataStore: dependencies.dataStore,
                projectValidator: dependencies.projectValidator
            )
        )
    }
    
    public var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .controlSize(.small)
                    .help("Validating \"Package.swift\" files")
            case let .error(text):
                Image(systemName: "power.circle")
                    .foregroundColor(.red)
                    .help("Error: \(text)")
            case let .warning(text):
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.orange)
                    .help("Warning: \(text)")
            case .valid:
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                    .help("\"Package.swift\" files are valid")
            }
        }
        .onTapGesture(perform: viewModel.onTap)
        .popover(item: $viewModel.presentedPopover) { popover in
            Text(popover.text)
                .padding()
        }
    }
}
