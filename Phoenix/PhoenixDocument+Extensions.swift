import UniformTypeIdentifiers
import PhoenixDocument
import DocumentCoderContract
import Factory
import SwiftPackage
import SwiftUI

extension UTType {
    static var ash: UTType {
        UTType(exportedAs: "com.tawanicolas.ash")
    }
}

extension PhoenixDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.ash] }

    public init(configuration: ReadConfiguration) throws {
        if configuration.file.isDirectory, let fileWrapper = configuration.file.fileWrappers {
            let phoenixDocumentFileWrappersDecoder = Container.phoenixDocumentFileWrappersDecoder()
            let phoenixDocument = try phoenixDocumentFileWrappersDecoder.phoenixDocument(from: fileWrapper)
            self = phoenixDocument
            print(self)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let phoenixDocumentFileWrapperEncoder = Container.phoenixDocumentFileWrapperEncoder()
        return try phoenixDocumentFileWrapperEncoder.fileWrapper(for: self)
    }
}
