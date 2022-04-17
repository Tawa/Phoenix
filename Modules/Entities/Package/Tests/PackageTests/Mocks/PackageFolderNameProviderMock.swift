@testable import Package

struct PackageFolderNameProviderMock: PackageFolderNameProviding {
    var value: String

    func folderName(for name: Name, of family: Family) -> String {
        value
    }
}
