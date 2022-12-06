import Combine
import Component
import PhoenixDocument
import SwiftUI

protocol PhoenixDocumentRepositoryProtocol {
    var value: PhoenixDocument { get }

    func bind(document: Binding<PhoenixDocument>)
    
    func family(named name: String) -> Family?
}

class PhoenixDocumentRepository: PhoenixDocumentRepositoryProtocol {
    var document: Binding<PhoenixDocument>!

    var value: PhoenixDocument { document.wrappedValue }
    
    private var subject: CurrentValueSubject<PhoenixDocument, Never>

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
    
    func family(named name: String) -> Family? {
        document.wrappedValue.families.first(where: { $0.family.name == name })?.family
    }
    
}
