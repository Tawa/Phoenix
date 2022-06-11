import Package
import SwiftUI

enum ComponentPopupState: Hashable, Identifiable {
    var id: Int { hashValue }
    case new
    case template(Component)
}

class ViewModel: ObservableObject {
    // MARK: - Selection
    @Published var selectedComponentName: Name? = nil
    @Published var selectedFamilyName: String? = nil

    // MARK: - Popovers
    @Published var showingConfigurationPopup: Bool = false
    @Published var showingNewComponentPopup: ComponentPopupState? = nil
    @Published var showingDependencyPopover: Bool = false
    @Published var fileErrorString: String? = nil

    private var pathsCache: [URL: URL] = [:]

    func update(value: String) {
        print("Value: \(value)")
    }

    func onConfigurationButton() {
        showingConfigurationPopup = true
    }

    func onAddButton() {
        showingNewComponentPopup = .new
    }

    func onDuplicate(component: Component) {
        showingNewComponentPopup = .template(component)
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
                                                   modules: document.projectConfiguration.packageConfigurations.reduce(into: [String: LibraryType](), { partialResult, packageConfiguration in
                    partialResult[packageConfiguration.name] = .undefined
                }),
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

        let componentExtractor = ComponentExtractor()
        let allFamilies: [Family] = document.families.map { $0.family }
        let packagesWithPath: [PackageWithPath] = document.families.flatMap { componentFamily -> [PackageWithPath] in
            let family = componentFamily.family
            return componentFamily.components.flatMap { (component: Component) -> [PackageWithPath] in
                componentExtractor.packages(for: component,
                                            of: family,
                                            allFamilies: allFamilies,
                                            projectConfiguration: document.projectConfiguration)
            }
        }

        let packagesGenerator = PackageGenerator()
        guard let folderURL = getPath(for: fileURL) else { return }
        for packageWithPath in packagesWithPath {
            let url = folderURL.appendingPathComponent(packageWithPath.path, isDirectory: true)
            do {
                try packagesGenerator.generate(package: packageWithPath.package, at: url)
            } catch {
                print(error)
            }
        }
    }

    private func openFolderSelection() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = true
        openPanel.runModal()
        return openPanel.url
    }

    private func getPath(for fileURL: URL) -> URL? {
        if let cache = pathsCache[fileURL] {
            return cache
        }

        guard let newURL = openFolderSelection() else { return nil }
        pathsCache[fileURL] = newURL
        return newURL
    }
}
