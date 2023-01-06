import PhoenixDocument

public protocol PackageFolderNameProviderProtocol {
    func folderName(for family: Family) -> String
}
