public protocol PackageFolderNameProviderProtocol {
    func folderName(for family: Family) -> String
}

public struct PackageFolderNameProvider: PackageFolderNameProviderProtocol {
    public let defaultFolderNameProvider: FamilyFolderNameProviderProtocol

    public init(defaultFolderNameProvider: FamilyFolderNameProviderProtocol) {
        self.defaultFolderNameProvider = defaultFolderNameProvider
    }

    public func folderName(for family: Family) -> String {
        family.folder ?? defaultFolderNameProvider.folderName(forFamily: family.name)
    }
}
