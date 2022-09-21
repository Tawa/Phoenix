import Component
import ComponentDetailsProviderContract
import XCTest
@testable import ComponentDetailsProvider

extension PackageConfiguration {
    static var contract: PackageConfiguration = .init(name: "Contract",
                                                      containerFolderName: "Contracts",
                                                      appendPackageName: true,
                                                      internalDependency: nil,
                                                      hasTests: false)
    static var implementation: PackageConfiguration = .init(name: "Implementation",
                                                            containerFolderName: nil,
                                                            appendPackageName: false,
                                                            internalDependency: "Contract",
                                                            hasTests: true)
    static var mock: PackageConfiguration = .init(name: "Mock",
                                                  containerFolderName: "Mocks",
                                                  appendPackageName: true,
                                                  internalDependency: nil,
                                                  hasTests: false)
}

final class PackagePathProviderTests: XCTestCase {
    
    lazy var packageFolderNameProviderMock = PackageFolderNameProviderMock(value: "PackageFolderName")
    lazy var packageNameProviderMock = PackageNameProviderMock(value: "PackageName")
    lazy var sut = PackagePathProvider(packageFolderNameProvider: packageFolderNameProviderMock,
                                       packageNameProvider: packageNameProviderMock)
    lazy var componentName = Name(given: "Given", family: "Family")
    lazy var family = Family(name: "Family", ignoreSuffix: false, folder: nil)

    func testContractRelativeToContract() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            packageConfiguration: .contract,
                            relativeToConfiguration: .contract)

        // Then
        XCTAssertEqual(path, "../../../Contracts/PackageFolderName/PackageName")
    }

    func testContractRelativeToImplementation() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            packageConfiguration: .contract,
                            relativeToConfiguration: .implementation)

        // Then
        XCTAssertEqual(path, "../../Contracts/PackageFolderName/PackageName")
    }

    func testContractRelativeToMock() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            packageConfiguration: .contract,
                            relativeToConfiguration: .mock)

        // Then
        XCTAssertEqual(path, "../../../Contracts/PackageFolderName/PackageName")
    }

    func testImplementationRelativeToContract() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            packageConfiguration: .implementation,
                            relativeToConfiguration: .contract)

        // Then
        XCTAssertEqual(path, "../../../PackageFolderName/PackageName")
    }

    func testImplementationRelativeToImplementation() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            packageConfiguration: .implementation,
                            relativeToConfiguration: .implementation)

        // Then
        XCTAssertEqual(path, "../../PackageFolderName/PackageName")
    }

    func testImplementationRelativeToMock() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            packageConfiguration: .implementation,
                            relativeToConfiguration: .mock)

        // Then
        XCTAssertEqual(path, "../../../PackageFolderName/PackageName")
    }

    func testMockRelativeToContract() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            packageConfiguration: .mock,
                            relativeToConfiguration: .contract)

        // Then
        XCTAssertEqual(path, "../../../Mocks/PackageFolderName/PackageName")
    }

    func testMockRelativeToImplementation() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            packageConfiguration: .mock,
                            relativeToConfiguration: .implementation)

        // Then
        XCTAssertEqual(path, "../../Mocks/PackageFolderName/PackageName")
    }

    func testMockRelativeToMock() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            packageConfiguration: .mock,
                            relativeToConfiguration: .mock)

        // Then
        XCTAssertEqual(path, "../../../Mocks/PackageFolderName/PackageName")
    }

}
