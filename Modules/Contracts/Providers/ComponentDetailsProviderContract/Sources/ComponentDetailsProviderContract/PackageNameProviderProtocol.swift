import PhoenixDocument

public protocol PackageNameProviderProtocol {
    func packageName(forComponentName componentName: Name,
                     of family: Family,
                     packageConfiguration: PackageConfiguration) -> String
}

