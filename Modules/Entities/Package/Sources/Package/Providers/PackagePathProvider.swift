public struct PackagePath {
    public let parent: String
    public let path: String

    public var full: String { parent + path }
}

protocol PackagePathProviding {
    func path(for name: Name,
              of family: Family,
              packageConfiguration: PackageConfiguration) -> String

    func path(for name: Name,
              of family: Family,
              packageConfiguration: PackageConfiguration,
              relativeToConfiguration: PackageConfiguration) -> String
}

struct PackagePathProvider: PackagePathProviding {
    private let packageFolderNameProvider: PackageFolderNameProviding
    private let packageNameProvider: PackageNameProviding

    init(packageFolderNameProvider: PackageFolderNameProviding, packageNameProvider: PackageNameProviding) {
        self.packageFolderNameProvider = packageFolderNameProvider
        self.packageNameProvider = packageNameProvider
    }

    func path(for name: Name, of family: Family, packageConfiguration: PackageConfiguration) -> String {
        var path: String = ""

        if let containerFolder = packageConfiguration.containerFolderName {
            path += containerFolder + "/"
        }

        path += packageFolderNameProvider.folderName(for: name, of: family) + "/"
        path += packageNameProvider.packageName(forComponentName: name, of: family, packageConfiguration: packageConfiguration)

        return path
    }

    func path(for name: Name,
              of family: Family,
              packageConfiguration: PackageConfiguration,
              relativeToConfiguration: PackageConfiguration) -> String {
        var path: String = ""
        if relativeToConfiguration.containerFolderName != nil {
            path = "../../../"
        } else {
            path = "../../"
        }

        if let containerFolder = packageConfiguration.containerFolderName {
            path += containerFolder + "/"
        }

        path += packageFolderNameProvider.folderName(for: name, of: family) + "/"
        path += packageNameProvider.packageName(forComponentName: name, of: family, packageConfiguration: packageConfiguration)

        return path
    }
}
