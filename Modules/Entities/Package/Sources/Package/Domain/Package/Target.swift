public struct Target: Codable, Hashable, Comparable {
    public let name: String
    public let dependencies: [Dependency]
    public let isTest: Bool
    public let resources: [TargetResources]
    
    public init(name: String, dependencies: [Dependency], isTest: Bool, resources: [TargetResources]) {
        self.name = name
        self.dependencies = dependencies
        self.isTest = isTest
        self.resources = resources
    }
    
    public static func <(lhs: Target, rhs: Target) -> Bool {
        lhs.name < rhs.name
    }
}
