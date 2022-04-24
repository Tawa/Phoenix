public struct Component: Codable, Hashable, Identifiable {
    public var id: Name { name }

    public let name: Name
    public var iOSVersion: IOSVersion?
    public var macOSVersion: MacOSVersion?
    public var modules: Set<ModuleType>
    public var dependencies: Set<ComponentDependency>

    public init(name: Name,
                iOSVersion: IOSVersion?,
                macOSVersion: MacOSVersion?,
                modules: Set<ModuleType>,
                dependencies: Set<ComponentDependency>) {
        self.name = name
        self.iOSVersion = iOSVersion
        self.macOSVersion = macOSVersion
        self.modules = modules
        self.dependencies = dependencies
    }
}

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
