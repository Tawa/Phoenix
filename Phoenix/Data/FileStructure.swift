import Package

struct Family: Codable, Hashable {
    let name: String
    var ignoreSuffix: Bool?
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
