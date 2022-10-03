import AccessibilityIdentifiers
import XCTest

protocol ComponentsList: Screen {
}

extension ComponentsList {
    
    func component(named: String) -> XCUIElement {
        Screen.app.otherElements[ComponentsListIdentifiers.component(named: named).identifier]
    }
    
    func familySettingsButton(named: String) -> XCUIElement {
        Screen.app.buttons[ComponentsListIdentifiers.familySettingsButton(named: named).identifier]
    }
    
    @discardableResult
    func selectComponent(named: String) -> ComponentsList {
        component(named: named).click()
        return self
    }
    
    @discardableResult
    func openSettings(forFamily family: String) -> ComponentsList {
        familySettingsButton(named: family).click()
        return self
    }
}
