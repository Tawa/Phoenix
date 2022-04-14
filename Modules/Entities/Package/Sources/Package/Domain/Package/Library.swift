public struct Library: Codable, Hashable {
    public let name: String
    public let type: LibraryType
    public let targets: [String]
}
