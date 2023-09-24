public struct SwiftPackage: Hashable {
    public let name: String
    public let defaultLocalization: String?
    public let platforms: Platforms
    public let products: [Product]
    public let dependencies: [Dependency]
    public let targets: [Target]
    public let swiftVersion: String
    
    public init(name: String,
                defaultLocalization: String?,
                platforms: Platforms,
                products: [Product],
                dependencies: [Dependency],
                targets: [Target],
                swiftVersion: String) {
        self.name = name
        self.defaultLocalization = defaultLocalization
        self.platforms = platforms
        self.products = products
        self.dependencies = dependencies
        self.targets = targets
        self.swiftVersion = swiftVersion
    }
}
