@testable import Phoenix
import PhoenixDocument
import XCTest

final class PhoenixDocumentMutatingExtensionTests: XCTestCase {
    func testRemoveComponentWithName_removesComponentsFromFamilyAndLocalDependencies() {
        // Given
        let navigatorName = Name(given: "Navigator", family: "Support")
        let navigatorComponent = Component(
            name: navigatorName,
            defaultLocalization: .init(),
            platforms: .empty,
            modules: [:],
            localDependencies: [],
            remoteDependencies: [],
            remoteComponentDependencies: [],
            macroComponentDependencies: [],
            resources: [],
            defaultDependencies: [:]
        )
        let supportFamily = ComponentsFamily(
            family: Family(name: "Support"),
            components: [navigatorComponent]
        )
        let featureFamily = ComponentsFamily(
            family: Family(name: "Features"),
            components: [
                Component(
                    name: Name(given: "Feature1", family: "Features"),
                    defaultLocalization: .init(),
                    platforms: .empty,
                    modules: [:],
                    localDependencies: [ComponentDependency(name: navigatorName, targetTypes: [:])],
                    remoteDependencies: [],
                    remoteComponentDependencies: [],
                    macroComponentDependencies: [],
                    resources: [],
                    defaultDependencies: [:]
                ),
                Component(
                    name: Name(given: "Feature2", family: "Features"),
                    defaultLocalization: .init(),
                    platforms: .empty,
                    modules: [:],
                    localDependencies: [ComponentDependency(name: navigatorName, targetTypes: [:])],
                    remoteDependencies: [],
                    remoteComponentDependencies: [],
                    macroComponentDependencies: [],
                    resources: [],
                    defaultDependencies: [:]
                ),
            ]
        )
        var sut = PhoenixDocument(
            families: [supportFamily, featureFamily]
        )

        // When
        sut.removeComponent(withName: navigatorName)

        // Then
        let components = sut.families.flatMap { $0.components }
        let localDependencies = components.flatMap { $0.localDependencies }
        XCTAssertFalse(localDependencies.contains(where: { $0.name.given == "Navigator" }))
        XCTAssertFalse(components.contains(where: { $0.name.given == "Navigator" }))
    }
}

