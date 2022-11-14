import Combine
import Component
import PhoenixDocument
import SwiftUI

protocol PhoenixDocumentRepositoryProtocol {
    var value: PhoenixDocument { get }
    var publisher: AnyPublisher<PhoenixDocument, Never> { get }
    
    func bind(document: Binding<PhoenixDocument>)
    
    func component(with id: String) -> Component?
    func deleteComponent(with id: String)
    func update(configuration: ProjectConfiguration)
    
    func family(with id: String) -> Family?
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
    
    func bind(document: Binding<PhoenixDocument>) {
        self.document = Binding(
            get: { document.wrappedValue },
            set: {
                document.wrappedValue = $0
                self.subject.send($0)
            })
        subject.send(document.wrappedValue)
    }
    
    func component(with id: String) -> Component? {
        value.componentsFamilies.flatMap(\.components).first(where: { $0.id == id })
    }
    
    func deleteComponent(with id: String) {
        guard let name = document
            .wrappedValue
            .families
            .flatMap(\.components)
            .first(where: { $0.id == id })?
            .name
        else { return }
        document.wrappedValue.removeComponent(withName: name)
    }
    
    func update(configuration: ProjectConfiguration) {
        document.wrappedValue.projectConfiguration = configuration
    }
    
    func family(with id: String) -> Family? {
        value.componentsFamilies.first(where: { $0.family.id == id })?.family
    }
}
