protocol PackagePathProviding {
    func path(for name: Name,
              of family: Family,
              type: ModuleType,
              relativeToType otherType: ModuleType) -> String
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
              relativeToType otherType: ModuleType) -> String {
        var path: String = ""

        switch otherType {
        case .contract:
            path += "../../../"
        case .implementation:
            path += "../../"
        case .mock:
            path += "../../../"
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

        return path
    }
}
