import Foundation
import ProjectValidatorContract

enum ProjectValidatorError: Error {
    case missingImplementation
}

public struct ProjectValidator: ProjectValidatorProtocol {
    public init() {
        
    }
    
    public func validate(fileURL: URL, modulesFolderURL: URL) async throws {
//        throw ProjectValidatorError.missingImplementation
    }
}
