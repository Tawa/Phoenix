public struct PackagePath {
    public let parent: String
    public let path: String

    public var full: String { parent + path }
}

protocol PackagePathProviding {
    func path(for name: Name,
              of family: Family,
              type: ModuleType,
              relativeToType otherType: ModuleType) -> PackagePath
}

struct PackagePathProvider: PackagePathProviding {
    private let packageFolderNameProvider: PackageFolderNameProviding
    private let packageNameProvider: PackageNameProviding

    init(packageFolderNameProvider: PackageFolderNameProviding, packageNameProvider: PackageNameProviding) {
        self.packageFolderNameProvider = packageFolderNameProvider
        self.packageNameProvider = packageNameProvider
    }

    func path(for name: Name,
              of family: Family,
              type: ModuleType,
              relativeToType otherType: ModuleType) -> PackagePath {
        var path: String = ""

        let parent: String
        switch otherType {
        case .contract:
            parent = "../../../"
        case .implementation:
            parent = "../../"
        case .mock:
            parent = "../../../"
        }

        switch type {
        case .contract:
            path += "Contracts/"
        case .implementation:
            break
        case .mock:
            path += "Mocks/"
        }

        path += packageFolderNameProvider.folderName(for: name, of: family) + "/"
        path += packageNameProvider.packageName(forType: type, name: name, of: family)

        return PackagePath(parent: parent, path: path)
    }
}
