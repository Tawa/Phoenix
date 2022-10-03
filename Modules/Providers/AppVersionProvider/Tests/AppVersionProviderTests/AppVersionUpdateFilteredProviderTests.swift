@testable import AppVersionProvider
import AppVersionProviderContract
import XCTest

final class AppVersionUpdateFilteredProviderTests: XCTestCase {
    
    func test_failure() {
        // Given
        let appVersionUpdateProviderMock = AppVersionUpdateProviderMock(result: .failure(ErrorMock.random))
        let appVersionStringParserMock = AppVersionStringParserMock(value: nil)
        let currentAppVersionProviderMock = CurrentAppVersionProviderMock(value: nil)
        
        let sut = AppVersionUpdateFilteredProvider(appVersionUpdateProvider: appVersionUpdateProviderMock,
                                                   appVersionStringParser: appVersionStringParserMock,
                                                   currentAppVersionProvider: currentAppVersionProviderMock)
        
        // When
        var resultError: Error?
        let exp = expectation(description: "Publisher publishes error")
        let sub = sut.appVersionsPublisher().sink { completion in
            switch completion {
            case .finished:
                break
            case let .failure(error):
                resultError = error
                exp.fulfill()
            }
        } receiveValue: { appVersions in
            
        }
        wait(for: [exp], timeout: 1)
        sub.cancel()
        
        // Then
        XCTAssertTrue(resultError is AppVersionUpdateError)
    }
    
    func test_success_emptyResults() {
        // Given
        let appVersionUpdateProviderMock = AppVersionUpdateProviderMock(result: .success(.init(results: [
            AppVersionInfo(version: "1.0.0", releaseNotes: "Older Version")
        ])))
        let appVersionStringParserMock = AppVersionStringParserMock(value: AppVersion(major: 1, minor: 0, hotfix: 0))
        let currentAppVersionProviderMock = CurrentAppVersionProviderMock(value: AppVersion(major: 2, minor: 0, hotfix: 0))
        
        let sut = AppVersionUpdateFilteredProvider(appVersionUpdateProvider: appVersionUpdateProviderMock,
                                                   appVersionStringParser: appVersionStringParserMock,
                                                   currentAppVersionProvider: currentAppVersionProviderMock)
        
        // When
        var resultAppVersions: AppVersions?
        let exp = expectation(description: "Publisher publishes error")
        let sub = sut.appVersionsPublisher().sink { _ in
        } receiveValue: { appVersions in
            resultAppVersions = appVersions
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        sub.cancel()
        
        // Then
        XCTAssertTrue(resultAppVersions?.results.isEmpty == true)
    }
    
    func test_success_1result() {
        // Given
        let appVersionUpdateProviderMock = AppVersionUpdateProviderMock(result: .success(.init(results: [
            AppVersionInfo(version: "3.0.0", releaseNotes: "Older Version")
        ])))
        let appVersionStringParserMock = AppVersionStringParserMock(value: AppVersion(major: 3, minor: 0, hotfix: 0))
        let currentAppVersionProviderMock = CurrentAppVersionProviderMock(value: AppVersion(major: 2, minor: 0, hotfix: 0))
        
        let sut = AppVersionUpdateFilteredProvider(appVersionUpdateProvider: appVersionUpdateProviderMock,
                                                   appVersionStringParser: appVersionStringParserMock,
                                                   currentAppVersionProvider: currentAppVersionProviderMock)
        
        // When
        var resultAppVersions: AppVersions?
        let exp = expectation(description: "Publisher publishes error")
        let sub = sut.appVersionsPublisher().sink { _ in
        } receiveValue: { appVersions in
            resultAppVersions = appVersions
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        sub.cancel()
        
        // Then
        XCTAssertEqual(resultAppVersions?.results.count, 1)
        XCTAssertEqual(resultAppVersions?.results.first?.version, "3.0.0")
    }
}
