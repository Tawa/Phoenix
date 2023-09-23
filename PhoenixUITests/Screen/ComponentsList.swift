import AccessibilityIdentifiers
import XCTest

protocol ComponentsList: Screen {
}

extension ComponentsList {
    
    func component(named: String) -> XCUIElement {
        Screen.app.buttons[ComponentsListIdentifiers.component(named: named).identifier]
    }
    
    func familySettingsButton(named: String) -> XCUIElement {
        Screen.app.buttons[ComponentsListIdentifiers.familySettingsButton(named: named).identifier]
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
    func selectAndAssertContractAndMock(component: String, andAddDependency dependencies: String...) -> Screen {
        let screen = self.selectComponent(named: component)
        dependencies.forEach { dependency in
            screen
                .addDependencyViaFilter(named: dependency)
                .assertContractAndMock(forDependency: dependency)
        }
        return screen
    }

    @discardableResult
    func selectAndAssertContractContractAndMock(component: String, andAddDependency dependencies: String...) -> Screen {
        let screen = self.selectComponent(named: component)
        dependencies.forEach { dependency in
            screen
                .addDependencyViaFilter(named: dependency)
                .assertContractContractAndMock(forDependency: dependency)
        }
        return screen
    }

    @discardableResult
    func openFamilySettings(named: String) -> FamilySheet {
        familySettingsButton(named: named).click()
        return FamilySheet()
    }

    @discardableResult
    func assertIOSPlatformUpdatedInComponent() -> ComponentsList {
        XCTAssertEqual(
            iOSVersionMenu.title,
            ".iOS(.v15)"
        )
        return self
    }
}
