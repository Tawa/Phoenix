import Combine
import Component
import PhoenixDocument
import SwiftUI

protocol PhoenixDocumentRepositoryProtocol {
    var componentsDictionary: [Name: SelectionPath] { get }
    var value: PhoenixDocument { get }

    func bind(document: Binding<PhoenixDocument>)
    
    func deleteComponent(with id: String)
    
    func family(named name: String) -> Family?
}

class PhoenixDocumentRepository: PhoenixDocumentRepositoryProtocol {
    var componentsDictionaryHash: Int = 0
    var componentsDictionary: [Name: SelectionPath] = [:]
    var document: Binding<PhoenixDocument>! {
        didSet {
            guard componentsDictionaryHash != document.wrappedValue.hashValue
            else { return }
            componentsDictionaryHash = document.wrappedValue.hashValue
            for familyIndex in 0..<document.families.count {
                for componentIndex in 0..<document.families[familyIndex].components.count {
                    let selectionPath = SelectionPath(name: document.families[familyIndex].components[componentIndex].wrappedValue.name)
                    let componentName = document.wrappedValue.families[familyIndex].components[componentIndex].name
                    componentsDictionary[componentName] = selectionPath
                }
            }
        }
    }

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
        
    func family(named name: String) -> Family? {
        document.wrappedValue.families.first(where: { $0.family.name == name })?.family
    }
    
}
