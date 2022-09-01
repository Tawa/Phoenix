import Package

public protocol PackagePathProviding {
    func path(for name: Name,
              of family: Family,
              packageConfiguration: PackageConfiguration) -> String

    func path(for name: Name,
              of family: Family,
              packageConfiguration: PackageConfiguration,
              relativeToConfiguration: PackageConfiguration) -> String
}
