import PhoenixDocument

extension ViewModel {
    func metasList(document: PhoenixDocument) -> [MetaComponent] {
        document.metaComponents
    }
}
