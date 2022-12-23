import Component
import PhoenixDocument

extension ViewModel {
    func remoteComponentsListRows(document: PhoenixDocument) -> [RemoteComponentsListRow] {
        remoteComponentsListRows(
            document: document,
            selectedId: nil,
            filter: componentsListFilter
        )
    }
    
    func remoteComponentsListRows(
        document: PhoenixDocument,
        selectedId: String?,
        filter: String?
    ) -> [RemoteComponentsListRow] {
        var remoteComponents = document.remoteComponents
        
        if let filter = filter?.lowercased() {
            remoteComponents = remoteComponents.filter { remoteComponent in
                remoteComponent.url.lowercased().contains(filter) ||
                remoteComponent.names.contains(where: { externalDependencyName in
                    externalDependencyName.name.lowercased().contains(filter) ||
                    externalDependencyName.package?.lowercased().contains(filter) ?? false
                })
            }
        }
        
        return remoteComponents
            .map { remoteComponent in
                RemoteComponentsListRow(
                    id: remoteComponent.url,
                    name: remoteComponent.url,
                    isSelected: remoteComponent.id == selectedId
                )
            }
    }
}
