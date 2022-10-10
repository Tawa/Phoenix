import AccessibilityIdentifiers
import XCTest

protocol DependencySheet: Screen {
    
}

extension DependencySheet {
    func selector(dependencyName: String, packageName: String) -> XCUIElement {
        Screen.app.popUpButtons[DependencyViewIdentifiers.menu(
            dependencyName: dependencyName,
            packageName: packageName
        ).identifier]
    }
    
    func option(dependencyName: String, packageName: String, option: String) -> XCUIElement {
        Screen.app.menuItems[DependencyViewIdentifiers.option(
            dependencyName: dependencyName,
            packageName: packageName,
            option: option
        ).identifier]
    }
    
    @discardableResult
    func clickSelector(dependencyName: String, packageName: String) -> DependencySheet {
        selector(dependencyName: dependencyName, packageName: packageName).click()
        return self
    }
    
    @discardableResult
    func assertSelector(dependencyName: String, packageName: String, label: String) -> DependencySheet {
        XCTAssertEqual(selector(dependencyName: dependencyName, packageName: packageName).title, label)
        return self
    }
    
    @discardableResult
    func click(dependencyName: String, packageName: String, option: String) -> Screen {
        self.option(dependencyName: dependencyName, packageName: packageName, option: option).click()
        return Screen()
    }
}
