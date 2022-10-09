import AccessibilityIdentifiers
import XCTest

protocol ComponentScreen: Screen {
}

extension ComponentScreen {
    var dependenciesPlusButton: XCUIElement {
        Screen.app.buttons[ComponentIdentifiers.dependenciesPlusButton.identifier]
    }
    
    @discardableResult
    func clickDependenciesPlusButton() -> DependenciesSheet {
        dependenciesPlusButton.click()
        return DependenciesSheet()
    }
    
    @discardableResult
    func addDependencyViaFilter(named: String) -> Screen {
        return self
            .clickDependenciesPlusButton()
            .filter(text: named)
            .tapEnter()
    }
    
    @discardableResult
    func addDependency(named: String) -> Screen {
        return self
            .clickDependenciesPlusButton()
            .clickComponent(named: named)
    }
}
