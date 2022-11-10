import Combine

protocol ComponentsFilterRepositoryProtocol {
    var value: String? { get }
    var publisher: AnyPublisher<String?, Never> { get }
    
    func update(value: String?)
}

class ComponentsFilterRepository: ComponentsFilterRepositoryProtocol {
    var value: String? {
        didSet {
            subject.send(value)
        }
    }
    private var subject: CurrentValueSubject<String?, Never> = .init(nil)
    var publisher: AnyPublisher<String?, Never> { subject.eraseToAnyPublisher() }
    
    init() {
        
    }
    
    func update(value: String?) {
        self.value = value
    }
}
