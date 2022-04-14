import Package
import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture

extension UTType {
    static var ash: UTType {
        UTType(exportedAs: "com.tawanicolas.ash")
    }
}

struct PhoenixDocument: FileDocument {
    var fileStructure: FileStructure

    init(fileStructure: FileStructure = FileStructure()) {
        self.fileStructure = fileStructure
    }

    static var readableContentTypes: [UTType] { [.ash] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.fileStructure = try JSONDecoder().decode(FileStructure.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(fileStructure)
        return .init(regularFileWithContents: data)
    }
}
