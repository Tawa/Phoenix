public struct PackageTargetType: Codable, Hashable, Identifiable, Comparable {
    public var id: Int { hashValue }
    public let name: String
    public let isTests: Bool

    public init(name: String, isTests: Bool) {
        self.name = name
        self.isTests = isTests
    }

    public static func <(lhs: PackageTargetType, rhs: PackageTargetType) -> Bool {
        guard lhs.name.lowercased() != rhs.name.lowercased()
        else { return !lhs.isTests }
        return lhs.name.lowercased() < rhs.name.lowercased()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isTests)
    }
}
