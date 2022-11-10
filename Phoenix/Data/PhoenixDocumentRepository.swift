import Combine
import Component
import PhoenixDocument
import SwiftUI

protocol PhoenixDocumentRepositoryProtocol {
    var value: PhoenixDocument { get }
    var publisher: AnyPublisher<PhoenixDocument, Never> { get }
    
    func component(with id: String) -> Component?
}

class PhoenixDocumentRepository: PhoenixDocumentRepositoryProtocol {
    var document: Binding<PhoenixDocument>!

    var value: PhoenixDocument { document.wrappedValue }
    
    private var subject: CurrentValueSubject<PhoenixDocument, Never>
    var publisher: AnyPublisher<PhoenixDocument, Never> {
        subject
            .eraseToAnyPublisher()
    }
    

    init(document: Binding<PhoenixDocument>) {
        self.subject = .init(document.wrappedValue)
        self.document = Binding(
            get: { document.wrappedValue },
            set: {
                document.wrappedValue = $0
                self.subject.send($0)
            })
    }
    
    func component(with id: String) -> Component? {
        value.componentsFamilies.flatMap(\.components).first(where: { $0.id == id })
    }
}
