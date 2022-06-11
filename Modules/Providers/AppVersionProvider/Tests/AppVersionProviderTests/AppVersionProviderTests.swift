import XCTest
@testable import AppVersionProvider
import AppVersionProviderContract

struct AppVersionStringProviderMock: CurrentAppVersionStringProviderProtocol {
    let value: String?

    func currentAppVersionString() -> String? {
        value
    }
}

struct AppVersionStringParserMock: AppVersionStringParserProtocol {
    let value: AppVersionProtocol?

    func appVersion(from string: String) -> AppVersionProtocol? {
        value
    }
}

final class AppVersionProviderTests: XCTestCase {

    func test_whenStringIsNilAndVersionIsNil_returnsNil() {
        // Given
        let appVersionStringProviderMock = AppVersionStringProviderMock(value: nil)
        let appVersionStringParserMock = AppVersionStringParserMock(value: nil)
        let sut = CurrentAppVersionProvider(appVersionStringProvider: appVersionStringProviderMock,
                                            appVersionStringParser: appVersionStringParserMock)

        // When
        let appVersion = sut.currentAppVersion()

        // Then
        XCTAssertNil(appVersion)
    }

    func test_whenStringIsNotNilAndVersionIsNil_returnsNil() {
        // Given
        let appVersionStringProviderMock = AppVersionStringProviderMock(value: "1.0.0")
        let appVersionStringParserMock = AppVersionStringParserMock(value: nil)
        let sut = CurrentAppVersionProvider(appVersionStringProvider: appVersionStringProviderMock,
                                            appVersionStringParser: appVersionStringParserMock)

        // When
        let appVersion = sut.currentAppVersion()

        // Then
        XCTAssertNil(appVersion)
    }

    func test_whenStringIsNilAndVersionIsNotNil_returnsNil() {
        // Given
        let appVersionStringProviderMock = AppVersionStringProviderMock(value: nil)
        let appVersionStringParserMock = AppVersionStringParserMock(value: AppVersion(major: 1, minor: 0, hotfix: 0))
        let sut = CurrentAppVersionProvider(appVersionStringProvider: appVersionStringProviderMock,
                                            appVersionStringParser: appVersionStringParserMock)

        // When
        let appVersion = sut.currentAppVersion()

        // Then
        XCTAssertNil(appVersion)
    }

    func test_whenStringIsNotNilAndVersionIsNotNil_returnsValue() {
        // Given
        let appVersionStringProviderMock = AppVersionStringProviderMock(value: "1.0.0")
        let appVersionStringParserMock = AppVersionStringParserMock(value: AppVersion(major: 1, minor: 2, hotfix: 3))
        let sut = CurrentAppVersionProvider(appVersionStringProvider: appVersionStringProviderMock,
                                            appVersionStringParser: appVersionStringParserMock)

        // When
        let appVersion = sut.currentAppVersion()

        // Then
        XCTAssertEqual(appVersion?.major, 1)
        XCTAssertEqual(appVersion?.minor, 2)
        XCTAssertEqual(appVersion?.hotfix, 3)
    }
}
