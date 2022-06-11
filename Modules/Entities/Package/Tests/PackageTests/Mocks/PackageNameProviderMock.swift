@testable import Package

struct PackageNameProviderMock: PackageNameProviding {
    var value: String

    func packageName(forComponentName componentName: Name, of family: Family, packageConfiguration: PackageConfiguration) -> String {
        value
    }
}
