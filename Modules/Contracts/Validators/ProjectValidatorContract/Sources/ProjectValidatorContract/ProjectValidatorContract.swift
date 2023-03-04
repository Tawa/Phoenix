import Foundation
import PhoenixDocument

public enum ProjectValidatorError: Error {
    case accessIsNotGranted
    case missingFiles
    case unsavedChanges
}

public protocol ProjectValidatorProtocol {
    func validate(
        document: PhoenixDocument,
        fileURL: URL,
        modulesFolderURL: URL
    ) async throws
}
