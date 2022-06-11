import Package
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var ash: UTType {
        UTType(exportedAs: "com.tawanicolas.ash")
    }
}

struct PhoenixDocument: FileDocument, Codable {
    var families: [ComponentsFamily]
    var projectConfiguration: ProjectConfiguration

    init(families: [ComponentsFamily] = [],
         projectConfiguration: ProjectConfiguration = .default) {
        self.families = families
        self.projectConfiguration = projectConfiguration
    }

    static var readableContentTypes: [UTType] { [.ash] }

    init(configuration: ReadConfiguration) throws {
        if configuration.file.isDirectory, let fileWrapper = configuration.file.fileWrappers {
            self = try PhoenixDocumentFileWrappersDecoder().phoenixDocument(from: fileWrapper)
        } else {
            guard let data = configuration.file.regularFileContents
            else {
                throw CocoaError(.fileReadCorruptFile)
            }
            self = try JSONDecoder().decode(PhoenixDocument.self, from: data)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        try PhoenixDocumentFileWrapperEncoder().fileWrapper(for: self)
    }
}
