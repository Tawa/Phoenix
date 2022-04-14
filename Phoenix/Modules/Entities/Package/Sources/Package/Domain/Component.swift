public struct Component: Codable, Hashable {
    public var name: Name
    public var types: [ModuleType: [Dependency]]
    public var platforms: [Platform]
}
