import Package

struct Family: Codable {
    var name: String
    var folderName: String
}

struct FileStructure: Codable {
    var components: [String: [Component]] = [:]
    var familyNames: [Family] = []
}
