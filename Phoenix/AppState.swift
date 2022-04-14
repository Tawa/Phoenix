import Package

struct FamilyName: Codable, Hashable, Identifiable {
    var id: String { singular }

    var singular: String
    var plural: String
}

struct FileStructure: Codable, Hashable {
    var components: [Component] = []
    var familyNames: [FamilyName] = []
}
