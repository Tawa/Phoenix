import Foundation
import PhoenixDocument

public protocol ProjectValidatorProtocol {
    func validate(
        document: PhoenixDocument,
        fileURL: URL,
        modulesFolderURL: URL
    ) async throws
}
