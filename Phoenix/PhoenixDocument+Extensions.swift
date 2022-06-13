import Package
import SwiftUI
import UniformTypeIdentifiers
import PhoenixDocument
import DocumentCoderContract
import Resolver

extension UTType {
    static var ash: UTType {
        UTType(exportedAs: "com.tawanicolas.ash")
    }
}

extension PhoenixDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.ash] }

    public init(configuration: ReadConfiguration) throws {
        if configuration.file.isDirectory, let fileWrapper = configuration.file.fileWrappers {
            @Injected var phoenixDocumentFileWrappersDecoder: PhoenixDocumentFileWrappersDecoderProtocol
            self = try phoenixDocumentFileWrappersDecoder.phoenixDocument(from: fileWrapper)
        } else {
            guard let data = configuration.file.regularFileContents
            else {
                throw CocoaError(.fileReadCorruptFile)
            }
            self = try JSONDecoder().decode(PhoenixDocument.self, from: data)
        }
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        @Injected var phoenixDocumentFileWrapperEncoder: PhoenixDocumentFileWrapperEncoderProtocol
        return try phoenixDocumentFileWrapperEncoder.fileWrapper(for: self)
    }
}
