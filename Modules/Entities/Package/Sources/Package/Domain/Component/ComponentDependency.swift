public struct ComponentDependency: Codable, Hashable, Identifiable {
    public var id: String { name.given + name.family }

    public let name: Name
    public var contract: ModuleType?
    public var implementation: ModuleType?
    public var tests: ModuleType?
    public var mock: ModuleType?

    public init(
        name: Name,
        contract: ModuleType?,
        implementation: ModuleType?,
        tests: ModuleType?,
        mock: ModuleType?
    ) {
        self.name = name
        self.contract = contract
        self.implementation = implementation
        self.tests = tests
        self.mock = mock
    }
}

public enum ComponentResourcesType: Codable, Hashable {
    case process
    case copy
}

public struct ComponentResources: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }

    public var folderName: String
    public var type: TargetResources.ResourcesType
    public var targets: [TargetType]
}
