@testable import ComponentDetailsProvider
import ComponentDetailsProviderContract
import PhoenixDocument

struct PackageNameProviderMock: PackageNameProviderProtocol {
    var value: String

    func packageName(forComponentName componentName: Name, of family: Family, packageConfiguration: PackageConfiguration) -> String {
        value
    }
}
