public protocol PackageNameProviding {
    func packageName(forType type: ModuleType, name: Name, of family: Family) -> String
}

public struct PackageNameProvider: PackageNameProviding {
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
