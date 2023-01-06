import ComponentDetailsProviderContract
@testable import ComponentDetailsProvider
import PhoenixDocument

struct PackageFolderNameProviderMock: PackageFolderNameProviderProtocol {
    var value: String

    func folderName(for family: Family) -> String {
        value
    }
}
