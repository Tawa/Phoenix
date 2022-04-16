public struct Name: Codable, Hashable, Identifiable {
    public var id: String { full }

    public let given: String
    public let family: String

    public var full: String { given + family }

    public init(given: String, family: String) {
        self.given = given
        self.family = family
    }
}
