public struct Component: Codable, Hashable, Identifiable {
    public var id: String { name.given + name.family }

    public var name: Name
    public var types: [ModuleType: [Dependency]]
    public var platforms: [Platform]

    public init(name: Name, types: [ModuleType : [Dependency]], platforms: [Platform]) {
        self.name = name
        self.types = types
        self.platforms = platforms
    }
}
