import Combine
import Component
import Foundation
import SwiftUI

protocol GetSelectedComponentUseCaseProtocol {
    var binding: Binding<Component> { get }
}

struct GetSelectedComponentUseCase: GetSelectedComponentUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    let getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol
    let selectionRepository: SelectionRepositoryProtocol
    
    var binding: Binding<Component> {
        Binding {
            getComponent(families: getComponentsFamiliesUseCase.families,
                         selection: selectionRepository.componentName)
        } set: {
            phoenixDocumentRepository.update(component: $0)
        }

    }
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol,
         getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol,
         selectionRepository: SelectionRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
        self.getComponentsFamiliesUseCase = getComponentsFamiliesUseCase
        self.selectionRepository = selectionRepository
    }
    
    private func getComponent(families: [ComponentsFamily], selection: Name?) -> Component {
        guard let selection,
              let familyIndex = families.firstIndex(where: { $0.family.name == selection.family }),
              let component = families[familyIndex].components.first(where: { $0.name == selection })
        else { return .default }
        return component
    }
}

private extension Component {
    static var `default`: Component {
        .init(
            name: .init(given: "", family: ""),
            defaultLocalization: .init(),
            iOSVersion: nil,
            macOSVersion: nil,
            modules: [:],
            dependencies: [],
            resources: [],
            defaultDependencies: [:])
    }
}
