public struct Component: Codable, Hashable, Identifiable {
    public var id: String { name.given + name.family }

    public var name: Name
    public var platforms: Set<Platform>
    public var types: [ModuleType: [Dependency]]

    public init(name: Name, platforms: Set<Platform>, types: [ModuleType : [Dependency]]) {
        self.name = name
        self.types = types
        self.platforms = platforms
    }
}
