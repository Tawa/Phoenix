import XCTest

final class PhoenixUITests: XCTestCase {

    let screen = Screen()

    func testExample() throws {
        screen
            .launch()
            .closeAllWindows()
            .newFile()
            .maximize()
            .openConfiguration()
            .addNew()
            .addNew()
            .type(text: "Contract", column: 0, row: 1)
            .type(text: "Contracts", column: 1, row: 1)
            .type(text: "Contract", column: 2, row: 0)
            .type(text: "Mock", column: 0, row: 2)
            .type(text: "Mocks", column: 1, row: 2)
            .type(text: "Contract", column: 2, row: 2)
            .close()
            .addNewComponent()
            .type(givenName: "Wordpress", familyName: "Repository")
            .clickCreate()
            .addNewComponent()
            .type(givenName: "Wordpress", familyName: "DataStore")
            .clickCreate()
            .addNewComponent()
            .type(givenName: "Wordpress", familyName: "Feature")
            .clickCreate()
            .addNewComponent()
            .type(givenName: "Wordpress", familyName: "UseCases")
            .clickCreate()
            .addNewComponent()
            .type(givenName: "Networking", familyName: "Support")
            .clickCreate()
            .openSettings(forFamily: "Supports")
    }
}
