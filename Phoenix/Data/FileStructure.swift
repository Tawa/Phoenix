import Package

struct Family: Codable, Hashable {
    var name: String
    var suffix: String?
    var folder: String?
}

struct ComponentsFamily: Codable, Hashable, Identifiable {
    var id: String { family.name }
    var family: Family
    var components: [Component]
}

struct FileStructure: Codable {
    var families: [ComponentsFamily] = []
    var selectedName: Name?
}
