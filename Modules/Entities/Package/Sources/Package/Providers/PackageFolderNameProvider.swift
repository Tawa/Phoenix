public protocol PackageFolderNameProviding {
    func folderName(for name: Name, of family: Family) -> String
}

public struct PackageFolderNameProvider: PackageFolderNameProviding {
    let defaultFolderNameProvider: FamilyFolderNameProviding

    public func folderName(for name: Name, of family: Family) -> String {
        family.folder ?? defaultFolderNameProvider.folderName(forFamily: family.name)
    }
}
