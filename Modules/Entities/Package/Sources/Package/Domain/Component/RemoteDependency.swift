public struct RemoteDependency: Codable, Hashable, Identifiable {
    public var id: String { url }

    public let url: String
    public var name: ExternalDependencyName
    public var version: ExternalDependencyVersion
    public var contract: Bool = false
    public var implementation: Bool = false
    public var tests: Bool = false
    public var mock: Bool = false

    public init(url: String,
                name: ExternalDependencyName,
                value: ExternalDependencyVersion) {
        self.url = url
        self.name = name
        self.version = value
    }
}
