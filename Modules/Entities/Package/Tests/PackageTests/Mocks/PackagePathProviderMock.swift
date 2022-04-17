@testable import Package

struct PackagePathProviderMock: PackagePathProviding {
    var value: String

    func path(for name: Name, of family: Family, type: ModuleType, relativeToType otherType: ModuleType) -> String {
        value
    }
}
