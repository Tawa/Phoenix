public struct Component: Codable, Hashable, Identifiable {
    public var id: String { name.given + name.family }

    public let name: Name
    public var iOSVersion: iOSVersion?
    public var macOSVersion: macOSVersion?
    public var types: [ModuleType: [Dependency]]

    public init(name: Name, iOSVersion: iOSVersion?, macOSVersion: macOSVersion?, types: [ModuleType : [Dependency]]) {
        self.name = name
        self.iOSVersion = iOSVersion
        self.macOSVersion = macOSVersion
        self.types = types
    }
}
