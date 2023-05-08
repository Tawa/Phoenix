import AccessibilityIdentifiers
import XCTest

final class GenerateSheet: Screen {
    var modulesFolderButton: XCUIElement {
        Screen.app.buttons[GenerateSheetIdentifiers.modulesFolderButton.identifier]
    }
    
    var skipXcodeToggle: XCUIElement {
        Screen.app.checkBoxes[GenerateSheetIdentifiers.skipXcodeToggle.identifier]
    }
    
    var isSkipXcodeToggleEnabled: Bool {
        (skipXcodeToggle.value as? Int) == 1
    }
    
    var xcodeButton: XCUIElement {
        Screen.app.buttons[GenerateSheetIdentifiers.xcodeButton.identifier]
    }
    
    var generateButton: XCUIElement {
        Screen.app.buttons[GenerateSheetIdentifiers.generateButton.identifier]
    }
    
    var cancelButton: XCUIElement {
        Screen.app.buttons[GenerateSheetIdentifiers.cancelButton.identifier]
    }
    
    @discardableResult
    func openModulesFolder() -> GenerateSheet {
        modulesFolderButton.click()
        okButton.click()
        return self
    }
    
    @discardableResult
    func enableXcodeToggle() -> GenerateSheet {
        if !isSkipXcodeToggleEnabled {
            skipXcodeToggle.click()
        }
        
        XCTAssertTrue(isSkipXcodeToggleEnabled)
        
        return self
    }
    
    @discardableResult
    func cancel() -> Screen {
        cancelButton.click()
        
        return Screen()
    }
    
    @discardableResult
    func generate() -> Screen {
        generateButton.click()
        
        return Screen()
    }
}
