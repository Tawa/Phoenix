@testable import Package

struct PackageFolderNameProviderMock: PackageFolderNameProviderProtocol {
    var value: String

    func folderName(for name: Name, of family: Family) -> String {
        value
    }
}
