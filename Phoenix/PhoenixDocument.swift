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
    var selectedName: Name?
    var selectedFamilyName: String?

    init(families: [ComponentsFamily] = [],
         selectedName: Name? = nil,
         selectedFamilyName: String? = nil) {
        self.families = families
        self.selectedName = selectedName
        self.selectedFamilyName = selectedFamilyName
    }

    static var readableContentTypes: [UTType] { [.ash] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self = try JSONDecoder().decode(PhoenixDocument.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        let data = try jsonEncoder.encode(self)
        return .init(regularFileWithContents: data)
    }
}
