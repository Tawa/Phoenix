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
    private var subject: PassthroughSubject<Name?, Never> = .init()
    var publisher: AnyPublisher<Name?, Never> { subject.eraseToAnyPublisher() }
    
    init() {
        print("Created Selection Repository")
    }
    
    func select(name: Name) {
        self.value = name
    }
}
