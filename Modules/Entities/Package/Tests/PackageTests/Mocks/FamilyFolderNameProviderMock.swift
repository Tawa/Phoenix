@testable import Package

struct FamilyFolderNameProviderMock: FamilyFolderNameProviding {
    var value: String

    func folderName(forFamily familyName: String) -> String {
        value
    }
}

