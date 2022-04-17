public struct ModuleDescription: Codable, Hashable {
    public var dependencies: [Dependency]
    public var hasTests: Bool
    public var testsDependencies: [Dependency]

    public init(dependencies: [Dependency], hasTests: Bool, testsDependencies: [Dependency]) {
        self.dependencies = dependencies
        self.hasTests = hasTests
        self.testsDependencies = testsDependencies
    }
}

public enum Dependency: Codable, Hashable, Identifiable, Comparable {
    public var id: Int { hashValue }

    case module(path: String, name: String)

    public static func <(lhs: Dependency, rhs: Dependency) -> Bool {
        switch (lhs, rhs) {
        case (.module(let lhsPath, _) , .module(let rhsPath, _)):
            return lhsPath < rhsPath
        }
    }
}
