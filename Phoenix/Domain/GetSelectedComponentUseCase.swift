import Combine
import Component
import Foundation
import SwiftUI

protocol GetSelectedComponentUseCaseProtocol {
    var value: Component { get }
    var binding: Binding<Component> { get }
    var publisher: AnyPublisher<Component, Never> { get }
}

struct GetSelectedComponentUseCase: GetSelectedComponentUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    let getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol
    let selectionRepository: SelectionRepositoryProtocol
    
    var value: Component {
        getComponent(families: getComponentsFamiliesUseCase.families,
                     selectionPath: selectionRepository.selectionPath)
    }
    
    var binding: Binding<Component> {
        Binding {
            getComponent(families: getComponentsFamiliesUseCase.families,
                         selectionPath: selectionRepository.selectionPath)
        } set: {
            phoenixDocumentRepository.update(component: $0)
        }
    }
    
    var publisher: AnyPublisher<Component, Never> {
        Publishers.CombineLatest(
            getComponentsFamiliesUseCase.familiesPublisher,
            selectionRepository.selectionPathPublisher
        )
        .map { (families, selectionPath) in
            self.getComponent(families: families, selectionPath: selectionPath)
        }
        .eraseToAnyPublisher()
    }
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol,
         getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol,
         selectionRepository: SelectionRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
        self.getComponentsFamiliesUseCase = getComponentsFamiliesUseCase
        self.selectionRepository = selectionRepository
    }
    
    private func getComponent(families: [ComponentsFamily], selectionPath: SelectionPath?) -> Component {
        guard
            let selectionPath,
            let familyIndex = families.firstIndex(where: { $0.family.name == selectionPath.name.family }),
            let componentIndex = families[familyIndex].components.firstIndex(where: { $0.name == selectionPath.name })
        else { return families.first?.components.first ?? .default  }
        return families[familyIndex].components[componentIndex]
    }
}

private extension Component {
    static var `default`: Component {
        .init(
            name: .empty,
            defaultLocalization: .init(),
            iOSVersion: nil,
            macOSVersion: nil,
            modules: [:],
            localDependencies: [],
            remoteDependencies: [],
            resources: [],
            defaultDependencies: [:])
    }
}
