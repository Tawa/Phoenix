@testable import Component
import XCTest

final class ComponentDependencyTypeTests: XCTestCase {

    func testLocalId() {
        // Given
        let componentDependencyType = ComponentDependencyType.local(
            ComponentDependency(
                name: Name(given: "Given", family: "Family"),
                targetTypes: [:])
        )
        
        // When
        let id = componentDependencyType.id
        
        // Then
        XCTAssertEqual(id, "GivenFamily")
    }
    
    func testRemoveId() {
        // Given
        let componentDependencyType = ComponentDependencyType.remote(
            RemoteDependency(url: "url",
                             name: .name("Name"),
                             value: .branch(name: "main"))
        )
        
        // When
        let id = componentDependencyType.id
        
        // Then
        XCTAssertEqual(id, "url")
    }
    
    func testComparison() {
        // Given
        let localComponentDependencyType1 = ComponentDependencyType.local(
            ComponentDependency(
                name: Name(given: "Given1", family: "Family"),
                targetTypes: [:])
        )
        let localComponentDependencyType2 = ComponentDependencyType.local(
            ComponentDependency(
                name: Name(given: "Given2", family: "Family"),
                targetTypes: [:])
        )
        let remoteComponentDependencyType1 = ComponentDependencyType.remote(
            RemoteDependency(url: "url1",
                             name: .name("Name"),
                             value: .branch(name: "main"))
        )
        let remoteComponentDependencyType2 = ComponentDependencyType.remote(
            RemoteDependency(url: "url2",
                             name: .name("Name"),
                             value: .branch(name: "main"))
        )

        // Then
        XCTAssertTrue(localComponentDependencyType1 < localComponentDependencyType2)
        XCTAssertTrue(remoteComponentDependencyType1 < remoteComponentDependencyType2)
        XCTAssertTrue(localComponentDependencyType1 < remoteComponentDependencyType1)
        XCTAssertFalse(remoteComponentDependencyType2 < localComponentDependencyType2)
    }
}
