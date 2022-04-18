public struct Target: Codable, Hashable, Comparable {
    public let name: String
    public let dependencies: [Dependency]
    public let isTest: Bool

    public static func <(lhs: Target, rhs: Target) -> Bool {
        lhs.name < rhs.name
    }
}
