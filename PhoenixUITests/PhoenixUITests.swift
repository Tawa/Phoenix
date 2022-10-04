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
            .select(option: "Contract", dependencyName: "NetworkingSupport", packageName: "Implementation")
            .select(option: "Mock", dependencyName: "NetworkingSupport", packageName: "Tests")
            .addDependencyViaFilter(named: "WordpressDataStore")
            .select(option: "Contract", dependencyName: "WordpressDataStore", packageName: "Implementation")
            .select(option: "Mock", dependencyName: "WordpressDataStore", packageName: "Tests")
            .selectComponent(named: "WordpressUseCases")
            .addDependencyViaFilter(named: "WordpressRepository")
            .select(option: "Contract", dependencyName: "WordpressRepository", packageName: "Implementation")
            .select(option: "Mock", dependencyName: "WordpressRepository", packageName: "Tests")
            .selectComponent(named: "WordpressFeature")
            .addDependencyViaFilter(named: "WordpressUseCases")
            .select(option: "Contract", dependencyName: "WordpressUseCases", packageName: "Implementation")
            .select(option: "Mock", dependencyName: "WordpressUseCases", packageName: "Tests")
    }
}
