public struct SwiftPackage: Hashable {
    public let name: String
    public let defaultLocalization: String?
    public let iOSVersion: IOSVersion?
    public let macCatalystVersion: MacCatalystVersion?
    public let macOSVersion: MacOSVersion?
    public let tvOSVersion: TVOSVersion?
    public let watchOSVersion: WatchOSVersion?
    public let products: [Product]
    public let dependencies: [Dependency]
    public let targets: [Target]
    public let swiftVersion: String
    
    public init(name: String,
                defaultLocalization: String?,
                iOSVersion: IOSVersion?,
                macCatalystVersion: MacCatalystVersion?,
                macOSVersion: MacOSVersion?,
                tvOSVersion: TVOSVersion?,
                watchOSVersion: WatchOSVersion?,
                products: [Product],
                dependencies: [Dependency],
                targets: [Target],
                swiftVersion: String) {
        self.name = name
        self.defaultLocalization = defaultLocalization
        self.iOSVersion = iOSVersion
        self.macCatalystVersion = macCatalystVersion
        self.macOSVersion = macOSVersion
        self.tvOSVersion = tvOSVersion
        self.watchOSVersion = watchOSVersion
        self.products = products
        self.dependencies = dependencies
        self.targets = targets
        self.swiftVersion = swiftVersion
    }
}
