public struct Component: Codable, Hashable, Identifiable {
    public var id: String { name.given + name.family }

    public let name: Name
    public var iOSVersion: iOSVersion?
    public var macOSVersion: macOSVersion?
    public var modules: Set<ModuleType>

    public init(name: Name, iOSVersion: iOSVersion?, macOSVersion: macOSVersion?, modules: Set<ModuleType>) {
        self.name = name
        self.iOSVersion = iOSVersion
        self.macOSVersion = macOSVersion
        self.modules = modules
    }
}
