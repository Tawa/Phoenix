public struct Name: Codable, Hashable {
    public let given: String
    public let family: String

    public init(given: String, family: String) {
        self.given = given
        self.family = family
    }
}
