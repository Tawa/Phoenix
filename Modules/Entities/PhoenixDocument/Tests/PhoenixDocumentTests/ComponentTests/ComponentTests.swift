@testable import PhoenixDocument
import XCTest

final class ComponentTests: XCTestCase {
    
    func testLocalDependenciesFilter() {
        // Given
        let component = Component(
            name: Name(given: "Wordpress", family: "Repository"),
            defaultLocalization: .init(),
            platforms: .empty,
            modules: [:],
            localDependencies: [
                ComponentDependency(name: Name(given: "Wordpress", family: "DataStore"),
                                           targetTypes: [:]),
                ComponentDependency(name: Name(given: "Networking", family: "Support"),
                                           targetTypes: [:])
            ],
            remoteDependencies: [
                RemoteDependency(url: "url", name: .name("name"), value: .branch(name: "main"), targetTypes: [])
            ],
            remoteComponentDependencies: [],
            macroComponentDependencies: [],
            resources: [],
            defaultDependencies: [:]
        )
        
        // When
        let localDependencies = component.localDependencies
        
        // Then
        XCTAssertEqual(localDependencies.count, 2)
        XCTAssertEqual(localDependencies.map(\.name), [
            Name(given: "Wordpress", family: "DataStore"),
            Name(given: "Networking", family: "Support")
        ])
    }

    func testDecode_canDecodePlatforms_whenDefinedOnOuterContainer() throws {
        // Given
        let jsonData = try XCTUnwrap(componentJSON.data(using: .utf8))
        let decoder = JSONDecoder()

        // When
        let component = try decoder.decode(Component.self, from: jsonData)
        let platforms = component.platforms

        // Then
        XCTAssertEqual(platforms.iOSVersion, .v15)
        XCTAssertNil(platforms.macOSVersion)
        XCTAssertEqual(platforms.tvOSVersion, .v13)
    }

    func testEncode_encodesPlatformsInOuterJSON() throws {
        // Given
        let expectedJSON = componentJSON
        let component = Component(
            name: .init(given: "HFDomain", family: "Core"),
            defaultLocalization: .init(),
            platforms: .init(iOSVersion: .v15, tvOSVersion: .v13),
            modules: [:],
            localDependencies: [],
            remoteDependencies: [],
            remoteComponentDependencies: [],
            macroComponentDependencies: [],
            resources: [],
            defaultDependencies: [:]
        )
        let encoder = JSONEncoder()

        // When
        let json = try encoder.encode(component)
        let jsonString = try XCTUnwrap(String(data: json, encoding: .utf8))

        // Then
        XCTAssertEqual(jsonString, expectedJSON)
    }
}

// MARK: - Samples
private extension ComponentTests {
    var componentJSON: String {
        #"""
        {"modules":{},"resources":[],"name":{"given":"HFDomain","family":"Core"},"tvOSVersion":"v13","iOSVersion":"v15"}
        """#
    }
}
