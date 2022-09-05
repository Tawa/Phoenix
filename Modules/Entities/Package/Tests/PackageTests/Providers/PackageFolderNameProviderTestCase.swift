@testable import Package
import XCTest

class PackageFolderNameProviderTestCase: XCTestCase {

    func testFamilyWithFolderName() {
        // Given
        let familyFolderNameProviderMock = FamilyFolderNameProviderMock(value: "Test")
        let family = Family(name: "Family", ignoreSuffix: false, folder: "FamilyFolder")
        let sut = PackageFolderNameProvider(defaultFolderNameProvider: familyFolderNameProviderMock)


        // When
        let folderName = sut.folderName(for: family)

        // Then
        XCTAssertEqual(folderName, "FamilyFolder")
    }

    func testFamilyWithoutFolderName() {
        // Given
        let familyFolderNameProviderMock = FamilyFolderNameProviderMock(value: "Test")
        let family = Family(name: "Family", ignoreSuffix: false, folder: nil)
        let sut = PackageFolderNameProvider(defaultFolderNameProvider: familyFolderNameProviderMock)


        // When
        let folderName = sut.folderName(for: family)

        // Then
        XCTAssertEqual(folderName, "Test")
    }
}
