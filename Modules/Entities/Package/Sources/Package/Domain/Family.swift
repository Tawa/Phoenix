public struct Family: Codable, Hashable {
    public let name: String
    public var ignoreSuffix: Bool?
    public var folder: String?

    public init(name: String, ignoreSuffix: Bool? = nil, folder: String? = nil) {
        self.name = name
        self.ignoreSuffix = ignoreSuffix
        self.folder = folder
    }
}
