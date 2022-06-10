public struct PackageConfiguration: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }
    public var name: String
    public var containerFolderName: String?
    public var appendPackageName: Bool
    public var internalDependency: String?
    public var hasTests: Bool

    public init(name: String, containerFolderName: String? = nil, appendPackageName: Bool, internalDependency: String? = nil, hasTests: Bool) {
        self.name = name
        self.containerFolderName = containerFolderName
        self.appendPackageName = appendPackageName
        self.internalDependency = internalDependency
        self.hasTests = hasTests
    }
}
