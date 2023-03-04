import Foundation
import PhoenixDocument
import DocumentCoderContract
import ProjectValidatorContract

public struct ProjectValidator: ProjectValidatorProtocol {
    let decoder: PhoenixDocumentFileWrappersDecoderProtocol
    let packagesValidator: PackagesValidatorProtocol
    
    public init(
        decoder: PhoenixDocumentFileWrappersDecoderProtocol,
        packagesValidator: PackagesValidatorProtocol
    ) {
        self.decoder = decoder
        self.packagesValidator = packagesValidator
    }
    
    public func validate(
        document: PhoenixDocument,
        fileURL: URL,
        modulesFolderURL: URL
    ) async throws {
        guard let fileWrappers = (try FileWrapper(url: fileURL)).fileWrappers
        else { throw ProjectValidatorError.missingFiles }
        
        let localDocument = try decoder.phoenixDocument(from: fileWrappers)
        
        guard localDocument.hashValue == document.hashValue
        else { throw ProjectValidatorError.unsavedChanges }
        
        try await packagesValidator.validate(
            document: document,
            modulesFolderURL: modulesFolderURL
        )
    }
}
