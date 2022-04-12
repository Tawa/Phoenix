@testable import PackageDescription
import XCTest

class FamilyFolderNameProviderTestCase: XCTestCase {

    func testStrings() {
        let familyNameFolderProvider = FamilyFolderNameProvider()

        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "Coordinator"), "Coordinators")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "DataStore"), "DataStores")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "Entity"), "Entities")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "Repository"), "Repositories")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "Service"), "Services")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "ViewModel"), "ViewModels")
    }
}
