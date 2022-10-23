import AccessibilityIdentifiers
import XCTest

class Screen: Toolbar, ComponentsList, ComponentScreen, DependencySheet {
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
            .selectDefaultDependenciesContractAndMock()
            .close()
    }
    
    @discardableResult
    func addNewComponent(givenName: String, familyName: String) -> Screen {
        return self
            .openNewComponentSheet()
            .type(givenName: givenName, familyName: familyName)
            .clickCreate()
            .assertComponent(givenName: givenName, familyName: familyName)
    }
    
    @discardableResult
    func select(option: String, dependencyName: String, packageName: String) -> Screen {
        return self
            .clickSelector(dependencyName: dependencyName, packageName: packageName)
            .click(dependencyName: dependencyName, packageName: packageName, option: option)
    }
    
    @discardableResult
    func selectContractAndMock(forDependency named: String) -> Screen {
        return self
            .select(option: "Contract", dependencyName: named, packageName: "Implementation")
            .select(option: "Mock", dependencyName: named, packageName: "Tests")
    }
    
    @discardableResult
    func assertComponent(givenName: String, familyName: String) -> Screen {
        XCTAssertTrue(component(named: givenName + familyName).exists,
                      "\(givenName + familyName) Component Not Found")
        return self
    }
    
    @discardableResult
    func assertContractAndMock(forDependency named: String) -> Screen {
        return self
            .assertSelector(dependencyName: named, packageName: "Implementation", title: "Contract")
            .assertSelector(dependencyName: named, packageName: "Tests", title: "Mock")
    }

    @discardableResult
    func assertContractContractAndMock(forDependency named: String) -> Screen {
        return self
            .assertSelector(dependencyName: named, packageName: "Contract", title: "Contract")
            .assertSelector(dependencyName: named, packageName: "Implementation", title: "Contract")
            .assertSelector(dependencyName: named, packageName: "Tests", title: "Mock")
    }

    @discardableResult
    func selectDefaultDependenciesContractContractAndMock() -> Screen {
        let dependencyName = "Default Dependencies"
        self
            .select(option: "Contract", dependencyName: dependencyName, packageName: "Contract")
            .select(option: "Contract", dependencyName: dependencyName, packageName: "Implementation")
            .select(option: "Mock", dependencyName: dependencyName, packageName: "Tests")
            .assertSelector(dependencyName: dependencyName, packageName: "Contract", title: "Contract")
            .assertSelector(dependencyName: dependencyName, packageName: "Implementation", title: "Contract")
            .assertSelector(dependencyName: dependencyName, packageName: "Tests", title: "Mock")
        return self
    }

}
