public protocol PackagesExtracting {
    func packages(for component: Component, of family: Family, allFamilies: [Family]) -> [Package]
}

public struct PackagesExtractor: PackagesExtracting {
    let packageExtractors: [ModuleType: PackageExtracting]

    public init(packageExtractors: [ModuleType: PackageExtracting]) {
        self.packageExtractors = packageExtractors
    }

    public func packages(for component: Component, of family: Family, allFamilies: [Family]) -> [Package] {
        component.modules.compactMap { packageExtractors[$0]?.package(for: component, of: family, allFamilies: allFamilies) }
    }
}
