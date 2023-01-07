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
        let expectedString = "{\"name\":{\"given\":\"Given\",\"family\":\"Family\"},\"targetTypes\":[{\"name\":\"Implementation\",\"isTests\":false},\"Contract\",{\"name\":\"Implementation\",\"isTests\":true},\"Mock\"]}"
        
        let componentDependency = ComponentDependency(
            name: Name(given: "Given", family: "Family"),
            targetTypes: [
                .init(name: "Implementation", isTests: false): "Contract",
                .init(name: "Implementation", isTests: true): "Mock"
            ])

        // When
        let data = try JSONEncoder().encode(componentDependency)
        let string = String(data: data, encoding: .utf8)
        
        // Then
        XCTAssertEqual(string, expectedString)
    }
}
