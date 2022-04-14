import Package

struct Family: Codable {
    var name: String
    var folderName: String
}

struct FileStructure: Codable {
    var components: [Component] = []
    var familyNames: [Family] = []
}
