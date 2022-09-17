@testable import SwiftPackage

struct PackageNameProviderMock: PackageNameProviderProtocol {
    var value: String

    func packageName(forComponentName componentName: Name, of family: Family, packageConfiguration: PackageConfiguration) -> String {
        value
    }
}
