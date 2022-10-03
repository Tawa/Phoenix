@testable import ComponentDetailsProvider
import XCTest

class FamilyFolderNameProviderTests: XCTestCase {

    func testStrings() {
        let familyNameFolderProvider = FamilyFolderNameProvider()

        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "Cactus"), "Cacti")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "Coordinator"), "Coordinators")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "DataStore"), "DataStores")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "Entity"), "Entities")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "Lunch"), "Lunches")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "Repository"), "Repositories")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "Service"), "Services")
        XCTAssertEqual(familyNameFolderProvider.folderName(forFamily: "ViewModel"), "ViewModels")
    }
}
