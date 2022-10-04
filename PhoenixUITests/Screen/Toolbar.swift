import AccessibilityIdentifiers
import XCTest

protocol Toolbar: Screen {
}

extension Toolbar {
    var configurationButton: XCUIElement {
        Screen.app.buttons[AccessibilityIdentifiers.Toolbar.configurationButton.identifier]
    }
    
    var newComponentButton: XCUIElement {
        Screen.app.buttons[AccessibilityIdentifiers.Toolbar.newComponentButton.identifier]
    }
    
    @discardableResult
    func openConfiguration() -> ConfigurationSheet {
        configurationButton.click()
        return ConfigurationSheet()
    }
    
    @discardableResult
    func openNewComponentSheet() -> NewComponentSheet {
        newComponentButton.click()
        return NewComponentSheet()
    }
}

