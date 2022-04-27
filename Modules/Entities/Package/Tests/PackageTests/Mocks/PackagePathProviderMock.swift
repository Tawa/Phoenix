@testable import Package

struct PackagePathProviderMock: PackagePathProviding {
    var value: PackagePath

    func path(for name: Name,
              of family: Family,
              type: ModuleType,
              relativeToType otherType: ModuleType) -> PackagePath {
        value
    }
}
