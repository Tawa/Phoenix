public protocol PackageNameProviding {
    func packageName(forComponentName componentName: Name,
                     of family: Family,
                     packageConfiguration: PackageConfiguration) -> String
}

public struct PackageNameProvider: PackageNameProviding {
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
    public func packageName(forType type: ModuleType, name: Name, of family: Family) -> String {
        var packageName: String = name.given
        if family.ignoreSuffix != true {
            packageName += name.family
        }

        switch type {
        case .contract:
            packageName += "Contract"
        case .implementation:
            break
        case .mock:
            packageName += "Mock"
        }

        return packageName
    }
}
