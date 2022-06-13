import Package
import Foundation
import AppVersionProviderContract
import PhoenixDocument

public protocol PhoenixDocumentFileWrappersDecoderProtocol {
    func phoenixDocument(from fileWrapper: [String: FileWrapper]) throws -> PhoenixDocument
}

public protocol PhoenixDocumentFileWrapperEncoderProtocol {
    func fileWrapper(for document: PhoenixDocument) throws -> FileWrapper
}
