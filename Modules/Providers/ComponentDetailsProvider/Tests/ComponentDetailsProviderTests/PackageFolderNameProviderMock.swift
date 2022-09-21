import Component
import ComponentDetailsProviderContract
@testable import ComponentDetailsProvider

struct PackageFolderNameProviderMock: PackageFolderNameProviderProtocol {
    var value: String

    func folderName(for family: Family) -> String {
        value
    }
}
