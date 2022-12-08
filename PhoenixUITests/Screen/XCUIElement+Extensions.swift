import XCTest

extension XCUIElement {
    func enter(text: String) {
        text.forEach { character in
            typeKey(String(character), modifierFlags: [])
        }
    }
}
