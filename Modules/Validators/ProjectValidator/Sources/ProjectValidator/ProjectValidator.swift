import Foundation
import PhoenixDocument
import ProjectValidatorContract

enum ProjectValidatorError: Error {
    case missingImplementation
}

public struct ProjectValidator: ProjectValidatorProtocol {
    public init() {
        
    }
    
    public func validate(
        document: PhoenixDocument,
        fileURL: URL,
        modulesFolderURL: URL
    ) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        //        throw ProjectValidatorError.missingImplementation
    }
}
