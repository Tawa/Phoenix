public struct Target: Codable, Hashable {
    public let name: String
    public let dependencies: [Dependency]
    public let isTest: Bool
}
