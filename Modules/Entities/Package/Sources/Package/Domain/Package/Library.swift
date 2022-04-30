public struct Library: Codable, Hashable, Comparable {
    public let name: String
    public let type: LibraryType
    public let targets: [String]

    public init(name: String, type: LibraryType, targets: [String]) {
        self.name = name
        self.type = type
        self.targets = targets
    }

    public static func <(lhs: Library, rhs: Library) -> Bool {
        lhs.name < rhs.name
    }
}
