import GenerateFeatureDataStoreContract
import ProjectValidatorContract
import SwiftUI

enum ValidationState {
    case loading
    case error(String)
    case valid
}

class ValidationFeatureViewModel: ObservableObject {
    let fileURL: URL?
    let dataStore: GenerateFeatureDataStoreProtocol
    let projectValidator: ProjectValidatorProtocol
   
    @MainActor
    @Published var state: ValidationState = .loading
    
    init(
        fileURL: URL?,
        dataStore: GenerateFeatureDataStoreProtocol,
        projectValidator: ProjectValidatorProtocol
    ) {
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
            try await Task.sleep(nanoseconds: 500_000_000)
            do {
                try await validateProject(fileURL: fileURL, modulesFolderURL: modulesFolderURL)
                await update(state: .valid)
            } catch {
                await update(state: .error("\(error)"))
            }
        }
    }
    
    private func validateProject(fileURL: URL, modulesFolderURL: URL) async throws {
        try await projectValidator.validate(
            fileURL: fileURL,
            modulesFolderURL: modulesFolderURL
        )
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
        fileURL: URL?,
        dependencies: ValidationFeatureDependencies
    ) {
        _viewModel = .init(
            initialValue: ValidationFeatureViewModel(
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
                Text(text)
                    .help("\"Package.swift\" file validation error: \(text)")
            case .valid:
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                    .help("\"Package.swift\" files are valid")
            }
        }
    }
}
