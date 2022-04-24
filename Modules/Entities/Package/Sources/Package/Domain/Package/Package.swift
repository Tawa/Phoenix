public struct Package: Codable, Hashable {
    public let name: String
    public let iOSVersion: IOSVersion?
    public let macOSVersion: MacOSVersion?
    public let products: [Product]
    public let dependencies: [Dependency]
    public let targets: [Target]
}
