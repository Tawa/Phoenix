import PhoenixDocument

extension ViewModel {
    func macrosList(document: PhoenixDocument) -> [MacroComponent] {
        document.macroComponents
    }
}
