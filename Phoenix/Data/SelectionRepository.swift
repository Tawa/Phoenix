import Combine
import Component

protocol SelectionRepositoryProtocol {
    var value: Name? { get }
    var publisher: AnyPublisher<Name?, Never> { get }
    
    func select(name: Name)
}

class SelectionRepository: SelectionRepositoryProtocol {
    var value: Name? = nil {
        didSet {
            subject.send(value)
        }
    }
    private var subject: CurrentValueSubject<Name?, Never> = .init(nil)
    var publisher: AnyPublisher<Name?, Never> { subject.eraseToAnyPublisher() }
    
    init() {
    }
    
    func select(name: Name) {
        self.value = name
    }
}
