import SwiftPackage

public protocol PackageStringProviderProtocol {
    func string(for package: SwiftPackage) -> String
}
