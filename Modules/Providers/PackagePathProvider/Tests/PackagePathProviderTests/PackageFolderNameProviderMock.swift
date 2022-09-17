@testable import SwiftPackage

struct PackageFolderNameProviderMock: PackageFolderNameProviderProtocol {
    var value: String

    func folderName(for family: Family) -> String {
        value
    }
}
