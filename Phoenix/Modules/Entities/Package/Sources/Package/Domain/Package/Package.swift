public struct Package: Codable, Hashable {
    public let name: String
    public let platforms: [Platform]
    public let products: [Product]
    public let targets: [Target]
}
