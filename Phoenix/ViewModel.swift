import Package
import SwiftUI

class ViewModel: ObservableObject {
    @Published var selectedComponentName: Name? = nil
    @Published var selectedFamilyName: String? = nil
    @Published var showingNewComponentPopup: Bool = false
    @Published var fileErrorString: String? = nil
    @Published var showingDependencyPopover: Name?

    func onAddButton() {
        showingNewComponentPopup = true
    }

    func onAddAll(document: inout PhoenixDocument) {
        var componentsFamilies = document.families
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
        document.families = componentsFamilies
    }

    func onGenerate(document: PhoenixDocument, withFileURL fileURL: URL?) {
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
