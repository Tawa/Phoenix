import Foundation
import PhoenixDocument
import DocumentCoderContract
import ProjectValidatorContract

enum ProjectValidatorError: Error {
    case missingFiles
    case unsavedChanges
}

public struct ProjectValidator: ProjectValidatorProtocol {
    let decoder: PhoenixDocumentFileWrappersDecoderProtocol
    
    public init(decoder: PhoenixDocumentFileWrappersDecoderProtocol) {
        self.decoder = decoder
    }
    
    public func validate(
        document: PhoenixDocument,
        fileURL: URL,
        modulesFolderURL: URL
    ) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        guard let fileWrappers = (try FileWrapper(url: fileURL)).fileWrappers
        else { throw ProjectValidatorError.missingFiles }
        
        let localDocument = try decoder.phoenixDocument(from: fileWrappers)
        
        guard localDocument.hashValue == document.hashValue
        else { throw ProjectValidatorError.unsavedChanges }
    }
}
