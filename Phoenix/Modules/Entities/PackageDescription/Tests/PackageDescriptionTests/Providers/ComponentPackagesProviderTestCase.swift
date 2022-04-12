@testable import PackageDescription
import XCTest

class ComponentModulesProviderTestCase: XCTestCase {

    func testComponentWithNoDependencies() throws {
        // Given
        let component = Component(name: Name(given: "Wordpress", family: "Repository"),
                                  types: [.contract, .implementation, .mock],
                                  platforms: [.macOS(.v12)],
                                  dependencies: [])
        let moduleFullNameProvider = ModuleFullNameProvider()
        let sut = ComponentModulesProvider(moduleFullNameProvider: moduleFullNameProvider)

        // When
        let modules = sut.modules(for: component)

        // Then
        XCTAssertEqual(modules.count, 3)

        XCTAssertEqual(modules[0].module.name, Name(given: "Wordpress", family: "Repository"))
        XCTAssertEqual(modules[0].module.type, .contract)
        XCTAssertEqual(modules[0].package.platforms, [.macOS(.v12)])
        XCTAssertEqual(modules[0].package.products, [.library(.init(name: "WordpressRepositoryContract",
                                                                    type: .dynamic,
                                                                    targets: ["WordpressRepositoryContract"]))])
        XCTAssertEqual(modules[0].package.targets, [Target(name: "WordpressRepositoryContract",
                                                           dependencies: [],
                                                           isTest: false)])

        XCTAssertEqual(modules[1].module.name, Name(given: "Wordpress", family: "Repository"))
        XCTAssertEqual(modules[1].module.type, .implementation)
        XCTAssertEqual(modules[1].package.platforms, [.macOS(.v12)])
        XCTAssertEqual(modules[1].package.products, [.library(.init(name: "WordpressRepository",
                                                                    type: .static,
                                                                    targets: ["WordpressRepository"]))])
        XCTAssertEqual(modules[1].package.targets, [Target(name: "WordpressRepository",
                                                           dependencies: ["WordpressRepositoryContract"],
                                                           isTest: false),
                                                    Target(name: "WordpressRepositoryTests",
                                                           dependencies: ["WordpressRepository"],
                                                           isTest: true)])

        XCTAssertEqual(modules[2].module.name, Name(given: "Wordpress", family: "Repository"))
        XCTAssertEqual(modules[2].module.type, .mock)
        XCTAssertEqual(modules[2].package.platforms, [.macOS(.v12)])
        XCTAssertEqual(modules[2].package.products, [.library(.init(name: "WordpressRepositoryMock",
                                                                    type: .dynamic,
                                                                    targets: ["WordpressRepositoryMock"]))])
        XCTAssertEqual(modules[2].package.targets, [Target(name: "WordpressRepositoryMock",
                                                           dependencies: ["WordpressRepositoryContract"],
                                                           isTest: false)])
    }
}
