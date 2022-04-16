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

public enum Dependency: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }

    case module(path: String, name: String)
}
