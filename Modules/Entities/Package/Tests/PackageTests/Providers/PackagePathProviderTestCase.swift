@testable import Package
import XCTest

class PackagePathProviderTestCase: XCTestCase {

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
                            type: .contract,
                            relativeToType: .contract)

        // Then
        XCTAssertEqual(path.full, "../../../Contracts/PackageFolderName/PackageName")
    }

    func testContractRelativeToImplementation() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            type: .contract,
                            relativeToType: .implementation)

        // Then
        XCTAssertEqual(path.full, "../../Contracts/PackageFolderName/PackageName")
    }

    func testContractRelativeToMock() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            type: .contract,
                            relativeToType: .mock)

        // Then
        XCTAssertEqual(path.full, "../../../Contracts/PackageFolderName/PackageName")
    }

    func testImplementationRelativeToContract() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            type: .implementation,
                            relativeToType: .contract)

        // Then
        XCTAssertEqual(path.full, "../../../PackageFolderName/PackageName")
    }

    func testImplementationRelativeToImplementation() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            type: .implementation,
                            relativeToType: .implementation)

        // Then
        XCTAssertEqual(path.full, "../../PackageFolderName/PackageName")
    }

    func testImplementationRelativeToMock() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            type: .implementation,
                            relativeToType: .mock)

        // Then
        XCTAssertEqual(path.full, "../../../PackageFolderName/PackageName")
    }

    func testMockRelativeToContract() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            type: .mock,
                            relativeToType: .contract)

        // Then
        XCTAssertEqual(path.full, "../../../Mocks/PackageFolderName/PackageName")
    }

    func testMockRelativeToImplementation() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            type: .mock,
                            relativeToType: .implementation)

        // Then
        XCTAssertEqual(path.full, "../../Mocks/PackageFolderName/PackageName")
    }

    func testMockRelativeToMock() {
        // When
        let path = sut.path(for: componentName,
                            of: family,
                            type: .mock,
                            relativeToType: .mock)

        // Then
        XCTAssertEqual(path.full, "../../../Mocks/PackageFolderName/PackageName")
    }

}
