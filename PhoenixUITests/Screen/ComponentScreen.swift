import AccessibilityIdentifiers
import XCTest

protocol ComponentScreen: Screen {
}

extension ComponentScreen {
    var dependenciesPlusButton: XCUIElement {
        Screen.app.buttons[ComponentIdentifiers.dependenciesPlusButton.identifier]
    }
    
    var localDependenciesButton: XCUIElement {
        Screen.app.buttons[ComponentIdentifiers.localDependenciesButton.identifier]
    }

    var remoteDependenciesButton: XCUIElement {
        Screen.app.buttons[ComponentIdentifiers.remoteDependenciesButton.identifier]
    }

    @discardableResult
    func clickDependenciesPlusButton() -> DependenciesSheet {
        dependenciesPlusButton.click()
        return DependenciesSheet()
    }

    @discardableResult
    func clickLocalDependenciesButton() -> Screen {
        localDependenciesButton.click()
        return self
    }
    
    @discardableResult
    func clickRemoteDependenciesButton() -> Screen {
        remoteDependenciesButton.click()
        return self
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
