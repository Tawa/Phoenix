public struct Component: Codable, Hashable, Identifiable {
    public var id: Name { name }

    public let name: Name
    public var iOSVersion: IOSVersion?
    public var macOSVersion: MacOSVersion?
    public var modules: [String: LibraryType]
    public var dependencies: [ComponentDependencyType]
    public var resources: [ComponentResources]

    public init(name: Name,
                iOSVersion: IOSVersion?,
                macOSVersion: MacOSVersion?,
                modules: [String: LibraryType],
                dependencies: [ComponentDependencyType],
                resources: [ComponentResources]) {
        self.name = name
        self.iOSVersion = iOSVersion
        self.macOSVersion = macOSVersion
        self.modules = modules
        self.dependencies = dependencies
        self.resources = resources
    }
}
