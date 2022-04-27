public struct RemoteDependency: Codable, Hashable, Identifiable {
    public var id: String { url }

    public let url: String
    public let name: ExternalDependencyName
    public let value: ExternalDependencyDescription
    public var contract: Bool = false
    public var implementation: Bool = false
    public var tests: Bool = false
    public var mock: Bool = false

    public init(url: String,
                name: ExternalDependencyName,
                value: ExternalDependencyDescription) {
        self.url = url
        self.name = name
        self.value = value
    }
}
