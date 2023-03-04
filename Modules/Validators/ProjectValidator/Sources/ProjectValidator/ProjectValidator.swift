import Foundation
import PhoenixDocument
import DocumentCoderContract
import ProjectValidatorContract

protocol FileAccessValidatorProtocol {
    func hasAccess(to url: URL) -> Bool
}

struct FileAccessValidator: FileAccessValidatorProtocol {
    func hasAccess(to url: URL) -> Bool {
        FileManager.default.isDeletableFile(atPath: url.path)
    }
}

public struct ProjectValidator: ProjectValidatorProtocol {
    let decoder: PhoenixDocumentFileWrappersDecoderProtocol
    let fileAccessValidator: FileAccessValidatorProtocol = FileAccessValidator()
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
        guard fileAccessValidator.hasAccess(to: fileURL)
        else { throw ProjectValidatorError.accessIsNotGranted }
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
