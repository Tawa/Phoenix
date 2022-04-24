public struct Component: Codable, Hashable, Identifiable {
    public var id: Name { name }

    public let name: Name
    public var iOSVersion: IOSVersion?
    public var macOSVersion: MacOSVersion?
    public var modules: Set<ModuleType>
    public var dependencies: Set<ComponentDependencyType>

    public init(name: Name,
                iOSVersion: IOSVersion?,
                macOSVersion: MacOSVersion?,
                modules: Set<ModuleType>,
                dependencies: Set<ComponentDependencyType>) {
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

public enum ComponentDependencyType: Codable, Hashable, Identifiable, Comparable {
    public var id: String {
        switch self {
        case let .local(value):
            return value.id
        }
    }

    case local(ComponentDependency)

    public static func <(lhs: ComponentDependencyType, rhs: ComponentDependencyType) -> Bool {
        switch (lhs, rhs) {
        case (.local(let lhsValue), .local(let rhsValue)):
            return lhsValue.id < rhsValue.id
        }
    }
}
