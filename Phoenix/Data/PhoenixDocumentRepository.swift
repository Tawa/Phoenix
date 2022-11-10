import Combine
import PhoenixDocument
import SwiftUI

protocol SelectionRepositoryProtocol {
    var value: String? { get set }
    var publisher: AnyPublisher<String?, Never> { get }
}

class SelectionRepository: SelectionRepositoryProtocol {
    var value: String? = nil {
        didSet {
            subject.send(value)
        }
    }
    private var subject: PassthroughSubject<String?, Never> = .init()
    var publisher: AnyPublisher<String?, Never> { subject.eraseToAnyPublisher() }
}

protocol GetSelectionUseCaseProtocol {
    var value: String? { get }
    var publisher: AnyPublisher<String?, Never> { get }
}

struct GetSelectionUseCase: GetSelectionUseCaseProtocol {
    let selectionRepository: SelectionRepositoryProtocol
    
    init(selectionRepository: SelectionRepositoryProtocol) {
        self.selectionRepository = selectionRepository
    }
    
    var value: String? { selectionRepository.value }
    var publisher: AnyPublisher<String?, Never> { selectionRepository.publisher }
}

protocol PhoenixDocumentRepositoryProtocol {
    var value: PhoenixDocument { get }
    var publisher: AnyPublisher<PhoenixDocument, Never> { get }
}

class PhoenixDocumentRepository: PhoenixDocumentRepositoryProtocol {
    var binding: Binding<PhoenixDocument>!

    var value: PhoenixDocument { binding.wrappedValue }
    
    private var subject: PassthroughSubject<PhoenixDocument, Never> = .init()
    var publisher: AnyPublisher<PhoenixDocument, Never> {
        subject
            .eraseToAnyPublisher()
    }
    

    init(_ binding: Binding<PhoenixDocument>) {
        self.binding = Binding(
            get: { binding.wrappedValue },
            set: {
                binding.wrappedValue = $0
                self.subject.send($0)
            })
    }
}
