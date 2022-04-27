import Package
import SwiftUI

class ComponentPreviewsViewModel: ObservableObject {
    private let component: Component
    private let extractor = PackagesExtractor()
    private let stringProvider = PackageStringProvider()

    var name: Name { component.name }

    @Published var preview: String = ""

    init(component: Component) {
        self.component = component
    }

    func load(family: Family?, allFamilies: [Family]) {
        guard let family = family else {
            preview = "Family Not Found"
            return
        }

        let packages = extractor.packages(for: component, of: family, allFamilies: allFamilies)
        preview = packages.map(\.package).map(stringProvider.string(for:)).joined(separator: "\n\n")
    }
}

struct ComponentPreviewsView: View {
    @EnvironmentObject private var store: PhoenixDocumentStore

    @StateObject private var viewModel: ComponentPreviewsViewModel

    init(component: Component) {
        _viewModel = .init(wrappedValue: ComponentPreviewsViewModel(component: component))
    }

    var body: some View {
        Text(viewModel.preview)
            .onAppear(perform: { viewModel.load(family: store.family(for: viewModel.name),
                                                allFamilies: store.componentsFamilies.map(\.family)) })
    }
}
