import AccessibilityIdentifiers
import XCTest

class Screen: Toolbar, ComponentsList {
    static let app = XCUIApplication()
    
    var window: XCUIElement {
        Screen.app.windows.firstMatch
    }
    
    var sheet: XCUIElement {
        Screen.app.sheets.firstMatch
    }
    
    @discardableResult
    func closeAllWindows() -> Screen {
        while Screen.app.windows.firstMatch.exists {
            Screen.app.windows.firstMatch.buttons[XCUIIdentifierCloseWindow].click()
        }
        return self
    }
    
    @discardableResult
    func newFile() -> Screen {
        Screen.app.typeKey("n", modifierFlags: .command)
        
        return self
    }
    
    @discardableResult
    func maximize() -> Screen {
        window.doubleClick()
        
        return self
    }
    
    @discardableResult
    func launch() -> Screen {
        Screen.app.launch()
        return self
    }
}
