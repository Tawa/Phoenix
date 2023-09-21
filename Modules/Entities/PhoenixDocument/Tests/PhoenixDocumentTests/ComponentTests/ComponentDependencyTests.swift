@testable import PhoenixDocument
import XCTest

final class ComponentDependencyTests: XCTestCase {

    func testId() {
        // Given
        let componentDependency = ComponentDependency(name: Name(given: "Given", family: "Family"),
                                                      targetTypes: [:])
        
        // When
        let id = componentDependency.id
        
        // Then
        XCTAssertEqual(id, "GivenFamily")
    }
    
    func testEncode() throws {
        // Given
        let expectedString = "{\"name\":{\"family\":\"Family\",\"given\":\"Given\"},\"targetTypes\":[{\"isTests\":false,\"name\":\"Implementation\"},\"Contract\",{\"isTests\":true,\"name\":\"Implementation\"},\"Mock\"]}"
        
        let componentDependency = ComponentDependency(
            name: Name(given: "Given", family: "Family"),
            targetTypes: [
                .init(name: "Implementation", isTests: false): "Contract",
                .init(name: "Implementation", isTests: true): "Mock"
            ])

        // When
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(componentDependency)
        let string = String(data: data, encoding: .utf8)
        
        // Then
        XCTAssertEqual(string, expectedString)
    }
}
