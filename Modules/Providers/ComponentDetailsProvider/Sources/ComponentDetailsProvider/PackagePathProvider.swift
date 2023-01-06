import ComponentDetailsProviderContract
import PhoenixDocument
import SwiftPackage

public struct PackagePathProvider: PackagePathProviderProtocol {
    private let packageFolderNameProvider: PackageFolderNameProviderProtocol
    private let packageNameProvider: PackageNameProviderProtocol
    
    public init(packageFolderNameProvider: PackageFolderNameProviderProtocol, packageNameProvider: PackageNameProviderProtocol) {
        self.packageFolderNameProvider = packageFolderNameProvider
        self.packageNameProvider = packageNameProvider
    }
    
    public func path(for name: Name,
                     of family: Family,
                     packageConfiguration: PackageConfiguration) -> String {
        var path: String = ""
        
        if let containerFolder = packageConfiguration.containerFolderName {
            path += containerFolder + "/"
        }
        
        path += packageFolderNameProvider.folderName(for: family) + "/"
        path += packageNameProvider.packageName(forComponentName: name, of: family, packageConfiguration: packageConfiguration)
        
        return path
    }
    
    public func path(for name: Name,
                     of family: Family,
                     packageConfiguration: PackageConfiguration,
                     relativeToConfiguration: PackageConfiguration) -> String {
        getPath(for: name,
                of: family,
                packageConfiguration: packageConfiguration,
                relativeToConfiguration: relativeToConfiguration)
    }
    
    public func getPath(for name: Name,
                        of family: Family,
                        packageConfiguration: PackageConfiguration,
                        relativeToConfiguration: PackageConfiguration?) -> String {
        var path: String = ""
        
        if let relativeToConfiguration {
            if relativeToConfiguration.containerFolderName != nil {
                path = "../../../"
            } else {
                path = "../../"
            }
        }
        
        if let containerFolder = packageConfiguration.containerFolderName {
            path += containerFolder + "/"
        }
        
        path += packageFolderNameProvider.folderName(for: family) + "/"
        path += packageNameProvider.packageName(forComponentName: name, of: family, packageConfiguration: packageConfiguration)
        
        return path
    }
}
