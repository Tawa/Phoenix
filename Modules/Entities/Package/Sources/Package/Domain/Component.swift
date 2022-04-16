public struct Component: Codable, Hashable, Identifiable {
    public var id: String { name.given + name.family }

    public let name: Name
    public var iOSVersion: iOSVersion?
    public var macOSVersion: macOSVersion?
    public var modules: [ModuleType: ModuleDescription]

    public init(name: Name, iOSVersion: iOSVersion?, macOSVersion: macOSVersion?, modules: [ModuleType: ModuleDescription]) {
        self.name = name
        self.iOSVersion = iOSVersion
        self.macOSVersion = macOSVersion
        self.modules = modules
    }
}
