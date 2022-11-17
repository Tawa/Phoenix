import XCTest
@testable import Component

final class ComponentTests: XCTestCase {
    
    func testId() {
        // Given
        let component = Component(
            name: Name(given: "Given", family: "Family"),
            defaultLocalization: .init(),
            iOSVersion: nil,
            macOSVersion: nil,
            modules: [:],
            dependencies: [],
            resources: [],
            defaultDependencies: [:])
        
        // When
        let id = component.id
        
        // Then
        XCTAssertEqual(id, Name(given: "Given", family: "Family"))
    }
    
    func testLocalDependenciesFilter() {
        // Given
        let component = Component(
            name: Name(given: "Wordpress", family: "Repository"),
            defaultLocalization: .init(),
            iOSVersion: nil,
            macOSVersion: nil,
            modules: [:],
            dependencies: [
                .local(ComponentDependency(name: Name(given: "Wordpress", family: "DataStore"),
                                           targetTypes: [:])),
                .local(ComponentDependency(name: Name(given: "Networking", family: "Support"),
                                           targetTypes: [:])),
                .remote(RemoteDependency(url: "url", name: .name("name"), value: .branch(name: "main")))
            ],
            resources: [],
            defaultDependencies: [:])
        
        // When
        let localDependencies = component.localDependencies
        
        // Then
        XCTAssertEqual(localDependencies.count, 2)
        XCTAssertEqual(localDependencies.map(\.name), [
            Name(given: "Wordpress", family: "DataStore"),
            Name(given: "Networking", family: "Support")
        ])
    }
}
