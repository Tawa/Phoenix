import XCTest
@testable import Component

final class ComponentTests: XCTestCase {
    
    func testLocalDependenciesFilter() {
        // Given
        let component = Component(
            name: Name(given: "Wordpress", family: "Repository"),
            defaultLocalization: .init(),
            iOSVersion: nil,
            macOSVersion: nil,
            modules: [:],
            localDependencies: [
                ComponentDependency(name: Name(given: "Wordpress", family: "DataStore"),
                                           targetTypes: [:]),
                ComponentDependency(name: Name(given: "Networking", family: "Support"),
                                           targetTypes: [:])
            ],
            remoteDependencies: [
                RemoteDependency(url: "url", name: .name("name"), value: .branch(name: "main"))
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
