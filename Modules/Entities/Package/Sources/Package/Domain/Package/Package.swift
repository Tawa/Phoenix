public struct Package: Codable, Hashable {
    public let name: String
    public let iOSVersion: iOSVersion?
    public let macOSVersion: macOSVersion?
    public let products: [Product]
    public let dependencies: [Dependency]
    public let targets: [Target]
}
