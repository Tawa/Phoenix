import AccessibilityIdentifiers
import XCTest

class Screen: Toolbar, ComponentsList, ComponentScreen {
    static let app = XCUIApplication()
    
    var window: XCUIElement {
        Screen.app.windows.firstMatch
    }
    
    var sheet: XCUIElement {
        Screen.app.sheets.firstMatch
    }
    
    @discardableResult
    func closeAllWindowsIfNecessary() -> Screen {
        while Screen.app.windows.firstMatch.exists {
            let closeButton = Screen.app.windows.firstMatch.buttons[XCUIIdentifierCloseWindow]
            if closeButton.exists {
                closeButton.click()
            }
            
            let deleteButton = Screen.app.windows.firstMatch.buttons["Delete"]
            if deleteButton.exists {
                deleteButton.click()
            }
            
            let cancelButton = Screen.app.windows.firstMatch.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.click()
            }
        }
        return self
    }
    
    @discardableResult
    func createNewFile() -> Screen {
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
    
    @discardableResult
    func configureContractImplementationAndMock() -> Screen {
        return self
            .openConfiguration()
            .addNew()
            .addNew()
            .type(text: "Contract", column: 0, row: 1)
            .type(text: "Contracts", column: 1, row: 1)
            .type(text: "Contract", column: 2, row: 0)
            .type(text: "Mock", column: 0, row: 2)
            .type(text: "Mocks", column: 1, row: 2)
            .type(text: "Contract", column: 2, row: 2)
            .close()
    }
    
    @discardableResult
    func addNewComponent(givenName: String, familyName: String) -> Screen {
        return self
            .openNewComponentSheet()
            .type(givenName: givenName, familyName: familyName)
            .clickCreate()
    }
}
