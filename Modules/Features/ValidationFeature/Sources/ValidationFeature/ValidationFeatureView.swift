import GenerateFeatureDataStoreContract
import LocalFileURLProviderContract
import PhoenixDocument
import ProjectValidatorContract
import SwiftUI

struct ValidationPopoverAction {
    let action: () -> Void
    let title: String
}

struct ValidationPopover: Identifiable {
    let id: String = UUID().uuidString
    let text: String
    let action: ValidationPopoverAction?
}

enum ValidationState {
    case loading
    case warning(String)
    case error(String, action: ValidationPopoverAction?)
    case valid
}

final class ValidationFeatureViewModel: ObservableObject {
    let ashFileURLProvider: LocalFileURLProviderProtocol
    let document: PhoenixDocument
    let fileURL: URL?
    let dataStore: GenerateFeatureDataStoreProtocol
    let onAshFileLoad: (URL?) -> Void
    let projectValidator: ProjectValidatorProtocol
   
    @Published var state: ValidationState = .loading
    @Published var presentedPopover: ValidationPopover?
    private var popoverText: String {
        switch state {
        case .loading:
            return "Validating Project"
        case .warning(let string):
            return string
        case .error(let string, _):
            return string
        case .valid:
            return "Packages and ash file are valid"
        }
    }
    private var popoverAction: ValidationPopoverAction? {
        switch state {
        case .loading, .warning, .valid:
            return nil
        case .error(_, let action):
            return action
        }
    }
    
    init(
        ashFileURLProvider: LocalFileURLProviderProtocol,
        document: PhoenixDocument,
        fileURL: URL?,
        dataStore: GenerateFeatureDataStoreProtocol,
        onAshFileLoad: @escaping (URL?) -> Void,
        projectValidator: ProjectValidatorProtocol
    ) {
        self.ashFileURLProvider = ashFileURLProvider
        self.document = document
        self.fileURL = fileURL
        self.dataStore = dataStore
        self.onAshFileLoad = onAshFileLoad
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
                await update(state: .error("Unsaved File", action: nil))
            }
            return
        }
        
        guard let modulesFolderURL = dataStore.getModulesFolderURL(forFileURL: fileURL)
        else {
            Task {
                await update(state: .error("Missing Modules Folder URL", action: nil))
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
                await update(state: .error("Access to modules folder is not granted",
                                           action: .init(action: self.grantAccessAction,
                                                         title: "Grant Access")))
            } catch ProjectValidatorError.missingFiles {
                await update(state: .error("Could not read local file", action: nil))
            } catch ProjectValidatorError.unsavedChanges {
                await update(state: .error("Unsaved Changes", action: nil))
            } catch PackagesValidatorError.projectOutOfSync(let warningText) {
                await update(state: .warning(warningText))
            } catch {
                await update(state: .error("\(error)", action: nil))
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
        self.presentedPopover = .init(text: popoverText, action: popoverAction)
    }
    
    private func grantAccessAction() {
        let localFileURL = self.ashFileURLProvider.localFileURL()
        onAshFileLoad(localFileURL)
    }
}

public struct ValidationFeatureDependencies {
    let ashFileURLProvider: LocalFileURLProviderProtocol
    let dataStore: GenerateFeatureDataStoreProtocol
    let onAshFileLoad: (URL?) -> Void
    let projectValidator: ProjectValidatorProtocol
    
    public init(ashFileURLProvider: LocalFileURLProviderProtocol,
                dataStore: GenerateFeatureDataStoreProtocol,
                onAshFileLoad: @escaping (URL?) -> Void,
                projectValidator: ProjectValidatorProtocol) {
        self.ashFileURLProvider = ashFileURLProvider
        self.dataStore = dataStore
        self.onAshFileLoad = onAshFileLoad
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
                ashFileURLProvider: dependencies.ashFileURLProvider,
                document: document,
                fileURL: fileURL,
                dataStore: dependencies.dataStore,
                onAshFileLoad: dependencies.onAshFileLoad,
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
            case let .error(text, _):
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
            HStack {
                Text(popover.text)
                if let action = popover.action {
                    Button(action.title, action: action.action)
                }
            }.padding()
        }
    }
}
