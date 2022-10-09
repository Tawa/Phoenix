import AccessibilityIdentifiers
import XCTest

protocol ComponentsList: Screen {
}

extension ComponentsList {
    
    func component(named: String) -> XCUIElement {
        Screen.app.buttons[ComponentsListIdentifiers.component(named: named).identifier]
    }
    
    func familySettingsButton(named: String) -> XCUIElement {
        Screen.app.staticTexts[ComponentsListIdentifiers.familySettingsButton(named: named).identifier]
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
    
    @discardableResult
    func select(component: String, andAddDependencyWithContractAndMock dependencies: String...) -> Screen {
        let screen = self.selectComponent(named: component)
        dependencies.forEach { dependency in
            screen
                .addDependencyViaFilter(named: dependency)
                .selectContractAndMock(forDependency: dependency)
        }
        return screen
    }
    
    @discardableResult
    func openFamilySettings(named: String) -> FamilySheet {
        familySettingsButton(named: named).click()
        return FamilySheet()
    }
}
