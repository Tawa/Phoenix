import Combine
import Component
import Foundation

struct SelectionPath: Equatable {
//    var familyIndex: Int
//    var componentIndex: Int
    var name: Name
}

protocol SelectionRepositoryProtocol {
//    var selectionPathPublisher: AnyPublisher<SelectionPath?, Never> { get }
//    var selectionPath: SelectionPath? { get }
//
//    func select(selectionPath: SelectionPath)
//
//    var familyName: String? { get }
//    var familyNamePublisher: AnyPublisher<String?, Never> { get }
//    func select(familyName: String)
//    func deselectFamilyName()
}

class SelectionRepository: SelectionRepositoryProtocol {
    private var selectionPathSubject: CurrentValueSubject<SelectionPath?, Never> = .init(nil)
    var selectionPathPublisher: AnyPublisher<SelectionPath?, Never> { selectionPathSubject.eraseToAnyPublisher() }
    var selectionPath: SelectionPath? {
        didSet {
            selectionPathSubject.send(selectionPath)
        }
    }

    var familyName: String? = nil {
        didSet {
            familyNameSubject.send(familyName)
        }
    }
    private var familyNameSubject: CurrentValueSubject<String?, Never> = .init(nil)
    var familyNamePublisher: AnyPublisher<String?, Never> { familyNameSubject.eraseToAnyPublisher() }
    
    init() {
    }
    
    func select(selectionPath: SelectionPath) {
        self.selectionPath = selectionPath
    }
    
    func select(familyName: String) {
        self.familyName = familyName
    }

    func deselectFamilyName() {
        familyName = nil
    }
}
