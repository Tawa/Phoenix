import Combine
import Component

protocol SelectionRepositoryProtocol {
    var componentName: Name? { get }
    var componentNamePublisher: AnyPublisher<Name?, Never> { get }
    
    var familyName: String? { get }
    var familyNamePublisher: AnyPublisher<String?, Never> { get }
    
    func select(name: Name)
    
    func select(familyName: String)
    func deselectFamilyName()
}

class SelectionRepository: SelectionRepositoryProtocol {
    var componentName: Name? = nil {
        didSet {
            componentNameSubject.send(componentName)
        }
    }
    private var componentNameSubject: CurrentValueSubject<Name?, Never> = .init(nil)
    var componentNamePublisher: AnyPublisher<Name?, Never> { componentNameSubject.eraseToAnyPublisher() }
    
    var familyName: String? = nil {
        didSet {
            familyNameSubject.send(familyName)
        }
    }
    private var familyNameSubject: CurrentValueSubject<String?, Never> = .init(nil)
    var familyNamePublisher: AnyPublisher<String?, Never> { familyNameSubject.eraseToAnyPublisher() }
    
    init() {
    }
    
    func select(name: Name) {
        self.componentName = name
    }
    
    func select(familyName: String) {
        self.familyName = familyName
    }

    func deselectFamilyName() {
        familyName = nil
    }
}
