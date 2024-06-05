public struct Target: Hashable, Comparable {
    public enum TargetType: String {
        case executableTarget
        case target
        case testTarget
        case macro
        case meta
    }
    
    public let name: String
    public let dependencies: [Dependency]
    public let resources: [TargetResources]
    public let type: TargetType
    
    public init(name: String, dependencies: [Dependency], resources: [TargetResources], type: TargetType) {
        self.name = name
        self.dependencies = dependencies
        self.type = type
        self.resources = resources
    }
    
    public static func <(lhs: Target, rhs: Target) -> Bool {
        lhs.name < rhs.name
    }
}
