import Combine
import SwiftUI

protocol ComponentsFilterRepositoryProtocol {
    var binding: Binding<String?> { get }

    var value: String? { get set }
    var publisher: AnyPublisher<String?, Never> { get }
}

class ComponentsFilterRepository: ComponentsFilterRepositoryProtocol {
    var binding: Binding<String?> {
        Binding { self.value } set: { self.value = $0 }
    }
    
    var value: String? {
        didSet {
            subject.send(value)
        }
    }
    private var subject: CurrentValueSubject<String?, Never> = .init(nil)
    var publisher: AnyPublisher<String?, Never> { subject.eraseToAnyPublisher() }
    
    init() {
    }
}
