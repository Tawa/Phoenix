import Package

public protocol PackageStringProviderProtocol {
    func string(for package: Package) -> String
}
