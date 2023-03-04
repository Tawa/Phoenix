import Foundation
import PhoenixDocument

public enum PackagesValidatorError: Error {
    case projectOutOfSync(String)
}

public protocol PackagesValidatorProtocol {
    func validate(
        document: PhoenixDocument,
        modulesFolderURL: URL
    ) async throws
}
