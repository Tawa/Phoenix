import AccessibilityIdentifiers
import XCTest

protocol Toolbar: Screen {
}

extension Toolbar {
    var configurationButton: XCUIElement {
        Screen.app.buttons[ToolbarIdentifiers.configurationButton.identifier].firstMatch
    }
    
    var newComponentButton: XCUIElement {
        Screen.app.buttons[ToolbarIdentifiers.newComponentButton.identifier].firstMatch
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

