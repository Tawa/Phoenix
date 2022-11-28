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
                         selectionPath: selectionRepository.selectionPath)
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
    
    private func getComponent(families: [ComponentsFamily], selectionPath: SelectionPath?) -> Component {
        guard let selectionPath,
              selectionPath.familyIndex < families.count,
              selectionPath.componentIndex < families[selectionPath.familyIndex].components.count
        else { return families.first?.components.first ?? .default }
        return families[selectionPath.familyIndex].components[selectionPath.componentIndex]
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
            localDependencies: [],
            remoteDependencies: [],
            resources: [],
            defaultDependencies: [:])
    }
}
