@testable import Package

struct FamilyFolderNameProviderMock: FamilyFolderNameProviderProtocol {
    var value: String

    func folderName(forFamily familyName: String) -> String {
        value
    }
}

