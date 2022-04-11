public struct PackageRepresentation {
    public let name: String
    public let platforms: [Platform]
    public let products: [Product]
    public let dependencies: [String]
    public let targets: [Target]
}
