public struct Family: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }

    public let name: String
    public var ignoreSuffix: Bool
    public var folder: String?

    public init(name: String, ignoreSuffix: Bool = false, folder: String? = nil) {
        self.name = name
        self.ignoreSuffix = ignoreSuffix
        self.folder = folder
    }
}
