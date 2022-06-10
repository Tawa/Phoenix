public struct PackageTargetType: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }
    public let name: String
    public let isTests: Bool

    public init(name: String, isTests: Bool) {
        self.name = name
        self.isTests = isTests
    }
}
