public struct ComponentsFamily: Codable, Hashable, Identifiable {
    public var id: String { family.name }
    public var family: Family
    public var components: [Component]
    
    public init(family: Family, components: [Component]) {
        self.family = family
        self.components = components
    }
}
