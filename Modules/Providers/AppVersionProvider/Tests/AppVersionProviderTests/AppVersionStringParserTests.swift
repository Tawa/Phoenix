@testable import AppVersionProvider
import XCTest

final class AppVersionStringParserTests: XCTestCase {

    let sut = AppVersionStringParser()
    
    let values: [(stringValue: String, expectedMajor: Int, expectedMinor: Int, expectedHotfix: Int)] = [
        ("", 0,0,0),
        ("1", 1,0,0),
        ("1.2", 1,2,0),
        ("1.2.3", 1,2,3),
        ("0.0.1", 0,0,1),
    ]
    
    func test_Values() {
        values.forEach { (stringValue: String, expectedMajor: Int, expectedMinor: Int, expectedHotfix: Int) in
            let version = sut.appVersion(from: stringValue)
            
            XCTAssertEqual(version?.major, expectedMajor)
            XCTAssertEqual(version?.minor, expectedMinor)
            XCTAssertEqual(version?.hotfix, expectedHotfix)
        }
    }
}
