import ComponentDetailsProviderContract
import PhoenixDocument

public struct PackageFolderNameProvider: PackageFolderNameProviderProtocol {
    public let defaultFolderNameProvider: FamilyFolderNameProviderProtocol

    public init(defaultFolderNameProvider: FamilyFolderNameProviderProtocol) {
        self.defaultFolderNameProvider = defaultFolderNameProvider
    }

    public func folderName(for family: Family) -> String {
        family.folder ?? defaultFolderNameProvider.folderName(forFamily: family.name)
    }
}
