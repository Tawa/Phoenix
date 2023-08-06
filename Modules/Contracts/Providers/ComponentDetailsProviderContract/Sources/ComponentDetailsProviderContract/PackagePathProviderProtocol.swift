import PhoenixDocument

public protocol PackagePathProviderProtocol {
    func path(for name: Name,
              of family: Family,
              packageConfiguration: PackageConfiguration) -> String

    func path(for name: Name,
              of family: Family,
              packageConfiguration: PackageConfiguration,
              relativeToConfiguration: PackageConfiguration) -> String
    
    func path(forMacro name: String,
              folderName: String,
              relativeToConfiguration: PackageConfiguration) -> String
}
