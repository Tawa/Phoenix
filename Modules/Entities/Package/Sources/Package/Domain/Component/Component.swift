public struct Component: Codable, Hashable, Identifiable {
    public var id: Name { name }

    public let name: Name
    public var iOSVersion: IOSVersion?
    public var macOSVersion: MacOSVersion?
    public var modules: Set<ModuleType>
    public var moduleTypes: [ModuleType: LibraryType]
    public var dependencies: Set<ComponentDependencyType>
    public var resources: [ComponentResources]

    public init(name: Name,
                iOSVersion: IOSVersion?,
                macOSVersion: MacOSVersion?,
                modules: Set<ModuleType>,
                moduleTypes: [ModuleType: LibraryType],
                dependencies: Set<ComponentDependencyType>,
                resources: [ComponentResources]) {
        self.name = name
        self.iOSVersion = iOSVersion
        self.macOSVersion = macOSVersion
        self.modules = modules
        self.moduleTypes = moduleTypes
        self.dependencies = dependencies
        self.resources = resources
    }
}
