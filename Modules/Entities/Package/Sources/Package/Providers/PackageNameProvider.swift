public protocol PackageNameProviderProtocol {
    func packageName(forComponentName componentName: Name,
                     of family: Family,
                     packageConfiguration: PackageConfiguration) -> String
}

public struct PackageNameProvider: PackageNameProviderProtocol {
    public init() {
        
    }
    
    public func packageName(forComponentName componentName: Name, of family: Family, packageConfiguration: PackageConfiguration) -> String {
        var name = componentName.given

        if !family.ignoreSuffix {
            name += family.name
        }

        if packageConfiguration.appendPackageName {
            name += packageConfiguration.name
        }

        return name
    }
}
