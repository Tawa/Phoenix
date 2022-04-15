import Package
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var ash: UTType {
        UTType(exportedAs: "com.tawanicolas.ash")
    }
}

struct PhoenixDocument: FileDocument {
    var components: [String: [Component]]
    var familyNames: [Family]

    init(fileStructure: FileStructure = FileStructure()) {
        self.components = fileStructure.components
        self.familyNames = fileStructure.familyNames
    }

    static var readableContentTypes: [UTType] { [.ash] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let fileStructure = try JSONDecoder().decode(FileStructure.self, from: data)

        self.components = fileStructure.components
        self.familyNames = fileStructure.familyNames
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let fileStructure = FileStructure(components: components,
                                          familyNames: familyNames)
        let data = try JSONEncoder().encode(fileStructure)
        return .init(regularFileWithContents: data)
    }
}
