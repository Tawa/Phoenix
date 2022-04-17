@testable import Package

struct PackageNameProviderMock: PackageNameProviding {
    var value: String

    func packageName(forType type: ModuleType, name: Name, of family: Family) -> String {
        value
    }
}
