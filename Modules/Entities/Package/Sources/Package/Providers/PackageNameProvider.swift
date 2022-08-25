public protocol PackageNameProviding {
    func packageName(forComponentName componentName: Name,
                     of family: Family,
                     packageConfiguration: PackageConfiguration) -> String
}

public struct PackageNameProvider: PackageNameProviding {
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
