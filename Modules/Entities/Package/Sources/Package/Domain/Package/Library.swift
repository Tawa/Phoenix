public struct Library: Codable, Hashable {
    public let name: String
    public let type: LibraryType?
    public let targets: [String]

    public init(name: String, type: LibraryType?, targets: [String]) {
        self.name = name
        self.type = type
        self.targets = targets
    }
}
