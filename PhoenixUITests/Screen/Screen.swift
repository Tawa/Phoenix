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
            let closeButton = Screen.app.windows.firstMatch.buttons[XCUIIdentifierCloseWindow]
            if closeButton.exists {
                closeButton.click()
            }
            
            let cancelButton = Screen.app.windows.firstMatch.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.click()
            }
            
            let deleteButton = Screen.app.windows.firstMatch.buttons["Delete"]
            if deleteButton.exists {
                deleteButton.click()
            }
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
