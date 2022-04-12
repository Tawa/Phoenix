public struct PackageDescription: Equatable {
    public let name: String
    public let platforms: [Platform]
    public let products: [Product]
    public let targets: [Target]
}
