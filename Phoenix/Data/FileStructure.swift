import Package

struct Family: Codable, Hashable {
    var name: String
    var folderName: String
}

struct FileStructure: Codable {
    var components: [String: [Component]] = [:]
    var familyNames: [Family] = []
    var selectedName: Name?
}
