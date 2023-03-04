import PhoenixDocument

public protocol DocumentPackagesProviderProtocol {
    func packages(for document: PhoenixDocument) -> [PackageWithPath]
}
