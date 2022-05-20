import Package
import SwiftUI

class ViewModel: ObservableObject {
    @Binding private var document: PhoenixDocument
    @Published var showingNewComponentPopup: Bool = false
    @Published var fileErrorString: String? = nil
    @Published var showingDependencyPopover: Bool = false
    let store: PhoenixDocumentStore
    let fileURL: URL?

    init(document: Binding<PhoenixDocument>,
         store: PhoenixDocumentStore,
         fileURL: URL?) {
        self._document = document
        self.store = store
        self.fileURL = fileURL
    }

    var selectedFamily: Binding<Family?> {
        Binding {
            guard
                let index = self.document.families.firstIndex(where: { $0.family.name == self.document.selectedFamilyName })
            else { return nil }
            return self.document.families[index].family
        } set: { newValue in
            guard
                let newValue = newValue,
                let index = self.document.families.firstIndex(where: { $0.family.name == self.document.selectedFamilyName })
            else {
                self.document.selectedFamilyName = nil
                return
            }
            self.document.families[index].family = newValue
        }
    }

    var componentsFamilies: Binding<[ComponentsFamily]> { Binding(get: { self.document.families },
                                                                  set: { self.document.families = $0 }) }

    var selectedName: Binding<Name?> { Binding(get: { self.document.selectedName },
                                               set: { self.document.selectedName = $0 }) }

    func onAddButton() {
        showingNewComponentPopup = true
    }

    func onFamilySelection(_ family: Family) {
        document.selectedFamilyName = family.name
    }

    func select(name: Name) {
        self.document.selectedName = name
    }

    func onAddAll() {
        var componentsFamilies = componentsFamilies.wrappedValue
        for familyIndex in 0..<10 {
            let familyName = "Family\(familyIndex)"
            var family = ComponentsFamily(family: Family(name: familyName,
                                                         ignoreSuffix: false,
                                                         folder: nil),
                                          components: [])
            for componentIndex in 0..<20 {
                family.components.append(Component(name: Name(given: "Component\(componentIndex)", family: familyName),
                                                   iOSVersion: nil,
                                                   macOSVersion: nil,
                                                   modules: [.contract: .dynamic,
                                                             .implementation: .static,
                                                             .mock: .undefined],
                                                   dependencies: [],
                                                   resources: []))
            }
            componentsFamilies.append(family)
        }
        self.componentsFamilies.wrappedValue = componentsFamilies
    }

    func onGenerate() {
        guard let fileURL = fileURL else {
            fileErrorString = "File must be saved before packages can be generated."
            return
        }

        let packagesExtractor = PackagesExtractor()
        let allFamilies: [Family] = document.families.map { $0.family }
        let packagesWithPath: [PackageWithPath] = document.families.flatMap { componentFamily -> [PackageWithPath] in
            let family = componentFamily.family
            return componentFamily.components.flatMap { (component: Component) -> [PackageWithPath] in
                packagesExtractor.packages(for: component, of: family, allFamilies: allFamilies)
            }
        }

        let packagesGenerator = PackageGenerator()
        for packageWithPath in packagesWithPath {
            let url = fileURL.deletingLastPathComponent().appendingPathComponent(packageWithPath.path, isDirectory: true)
            try? packagesGenerator.generate(package: packageWithPath.package, at: url)
        }
    }
}
