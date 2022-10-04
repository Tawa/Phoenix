import XCTest

final class PhoenixUITests: XCTestCase {

    let screen = Screen()

    func testExample() throws {
        screen
            .launch()
            .closeAllWindowsIfNecessary()
            .createNewFile()
            .maximize()
            .configureContractImplementationAndMock()
            .addNewComponent(givenName: "Wordpress", familyName: "Repository")
            .addNewComponent(givenName: "Wordpress", familyName: "DataStore")
            .addNewComponent(givenName: "Wordpress", familyName: "Feature")
            .addNewComponent(givenName: "Wordpress", familyName: "UseCases")
            .addNewComponent(givenName: "Networking", familyName: "Support")
            .selectComponent(named: "WordpressRepository")
            .addDependencyViaFilter(named: "Networking")
            .addDependencyViaFilter(named: "WordpressDataStore")
            .selectComponent(named: "WordpressUseCases")
            .addDependencyViaFilter(named: "WordpressRepository")
            .selectComponent(named: "WordpressFeature")
            .addDependencyViaFilter(named: "WordpressUseCases")
    }
}
