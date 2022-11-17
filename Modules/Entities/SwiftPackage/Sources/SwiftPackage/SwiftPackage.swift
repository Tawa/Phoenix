public struct SwiftPackage: Codable, Hashable {
    public let name: String
    public let defaultLocalization: String?
    public let iOSVersion: IOSVersion?
    public let macOSVersion: MacOSVersion?
    public let products: [Product]
    public let dependencies: [Dependency]
    public let targets: [Target]
    public let swiftVersion: String
    
    public init(name: String,
                defaultLocalization: String?,
                iOSVersion: IOSVersion?,
                macOSVersion: MacOSVersion?,
                products: [Product],
                dependencies: [Dependency],
                targets: [Target],
                swiftVersion: String) {
        self.name = name
        self.defaultLocalization = defaultLocalization
        self.iOSVersion = iOSVersion
        self.macOSVersion = macOSVersion
        self.products = products
        self.dependencies = dependencies
        self.targets = targets
        self.swiftVersion = swiftVersion
    }
}
