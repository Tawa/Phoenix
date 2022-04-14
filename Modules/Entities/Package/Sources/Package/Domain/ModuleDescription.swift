public struct ModuleDescription: Codable, Hashable {
    public let name: Name
    public let type: ModuleType
}

public enum Dependency: Codable, Hashable {
    case module(ModuleDescription)
}

