import AccessibilityIdentifiers
import XCTest

final class FamilySheet: Screen {
    var folderTextField: XCUIElement {
        Screen.app.textFields[FamilySheetIdentifiers.folderNameTextField.identifier]
    }
    
    var appendNameToggle: XCUIElement {
        Screen.app.checkBoxes[FamilySheetIdentifiers.appendNameToggle.identifier]
    }
    
    var doneButton: XCUIElement {
        Screen.app.buttons[FamilySheetIdentifiers.doneButton.identifier]
    }
    
    @discardableResult
    func set(folderName: String) -> FamilySheet {
        folderTextField.click()
        folderTextField.enter(text: folderName)
        return self
    }
    
    @discardableResult
    func toggleAppendName(familyName: String) -> FamilySheet {
        appendNameToggle.click()
        XCTAssertFalse(appendNameToggle.isSelected,
                       "Append Name toggle should not be selected for Family \(familyName)")
        return self
    }
    
    @discardableResult
    func clickDone() -> Screen {
        doneButton.click()
        return self
    }
}
