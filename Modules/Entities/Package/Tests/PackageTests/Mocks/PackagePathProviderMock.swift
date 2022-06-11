@testable import Package

struct PackagePathProviderMock: PackagePathProviding {
    var value: String

    func path(for name: Name, of family: Family, packageConfiguration: PackageConfiguration) -> String {
        value
    }
    func path(for name: Name, of family: Family, packageConfiguration: PackageConfiguration, relativeToConfiguration: PackageConfiguration) -> String {
        value
    }
}
