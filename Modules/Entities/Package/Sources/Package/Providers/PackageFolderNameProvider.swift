public protocol PackageFolderNameProviding {
    func folderName(for name: Name, of family: Family) -> String
}

public struct PackageFolderNameProvider: PackageFolderNameProviding {
    public let defaultFolderNameProvider: FamilyFolderNameProviding

    public init(defaultFolderNameProvider: FamilyFolderNameProviding) {
        self.defaultFolderNameProvider = defaultFolderNameProvider
    }

    public func folderName(for name: Name, of family: Family) -> String {
        family.folder ?? defaultFolderNameProvider.folderName(forFamily: family.name)
    }
}
