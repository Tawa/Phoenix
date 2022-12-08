import AccessibilityIdentifiers
import XCTest

class ConfigurationSheet: Screen {
    var addNewButton: XCUIElement {
        Screen.app.buttons[ConfigurationSheetIdentifiers.addNewButton.identifier]
    }
    
    var closeButton: XCUIElement {
        Screen.app.buttons[ConfigurationSheetIdentifiers.closeButton.identifier]
    }
    
    func textField(column: Int, row: Int) -> XCUIElement {
        Screen.app.textFields[
            ConfigurationSheetIdentifiers.textField(
                column: column,
                row: row
            ).identifier
        ]
    }
    
    @discardableResult
    func addNew() -> ConfigurationSheet {
        addNewButton.click()
        return self
    }
    
    @discardableResult
    func close() -> Screen {
        closeButton.click()
        return Screen()
    }
    
    @discardableResult
    func type(text: String, column: Int, row: Int) -> ConfigurationSheet {
        let cell = textField(column: column, row: row)
        cell.click()
        cell.typeKey("a", modifierFlags: .command)
        cell.enter(text: text)
        return self
    }
    
    @discardableResult
    func selectDefaultDependenciesContractAndMock() -> ConfigurationSheet {
        let dependencyName = "Default Dependencies"
        self
            .select(option: "Contract", dependencyName: dependencyName, packageName: "Implementation")
            .select(option: "Mock", dependencyName: dependencyName, packageName: "Tests")
            .assertSelector(dependencyName: dependencyName, packageName: "Implementation", title: "Contract")
            .assertSelector(dependencyName: dependencyName, packageName: "Tests", title: "Mock")
        return self
    }
}
