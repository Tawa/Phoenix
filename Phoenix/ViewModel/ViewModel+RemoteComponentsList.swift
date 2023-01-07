import PhoenixDocument

extension ViewModel {
    func remoteComponentsListRows(document: PhoenixDocument) -> [RemoteComponentsListRow] {
        remoteComponentsListRows(
            document: document,
            selectedURL: selection?.remoteComponentURL,
            filter: componentsListFilter
        )
    }
    
    func remoteComponentsListRows(
        document: PhoenixDocument,
        selectedURL: String?,
        filter: String?
    ) -> [RemoteComponentsListRow] {
        document.remoteComponents
            .filtered(filter)
            .map { remoteComponent in
                RemoteComponentsListRow(
                    id: remoteComponent.url,
                    name: remoteComponent.url,
                    isSelected: remoteComponent.url == selectedURL
                )
            }
    }
}
