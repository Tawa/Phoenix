import Component

public protocol PackageFolderNameProviderProtocol {
    func folderName(for family: Family) -> String
}
