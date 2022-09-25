import Component
import ComponentDetailsProviderContract
import DemoAppGeneratorContract
import PBXProjectSyncerContract
import PhoenixDocument
import SwiftPackage
import SwiftUI

public struct DemoAppDependencyTargetTypeSelection: Identifiable {
    public var id = UUID().uuidString
    
    let targetType: String
    var isSelected: Bool
}

public struct DemoAppDependencyViewModel: Identifiable {
    public var id = UUID().uuidString
    
    let title: String
    var targetTypesSelected: [DemoAppDependencyTargetTypeSelection]
}

class DemoAppFeatureViewModel: ObservableObject {
    let title: String
    @Published var organizationIdentifier: String = ""
    @Published var isListLoading: Bool = false
    @Published var dependencies: [DemoAppDependencyViewModel] = []
    
    init(
        title: String,
        organizationIdentifier: String
    ) {
        self.title = title
        self.organizationIdentifier = organizationIdentifier
    }
}


struct DemoAppFeaturePresenter {
    let viewModel: DemoAppFeatureViewModel
    
    func startLoadingList() {
        viewModel.isListLoading = true
    }
    
    func stopLoadingList() {
        viewModel.isListLoading = false
    }
    
    func update(dependencies: [DemoAppDependencyViewModel]) {
        viewModel.dependencies = dependencies
    }
}

struct DemoAppFeatureInteractor {
    private let ashFileURL: URL
    private let component: Component
    private let demoAppGenerator: DemoAppGeneratorProtocol
    private let document: PhoenixDocument
    private let packageNameProvider: PackageNameProviderProtocol
    private let pbxProjectSyncer: PBXProjectSyncerProtocol
    private let presenter: DemoAppFeaturePresenter
    private let cancelAction: () -> Void
    
    init(
        ashFileURL: URL,
        component: Component,
        document: PhoenixDocument,
        packageNameProvider: PackageNameProviderProtocol,
        pbxProjectSyncer: PBXProjectSyncerProtocol,
        presenter: DemoAppFeaturePresenter,
        demoAppGenerator: DemoAppGeneratorProtocol,
        cancelAction: @escaping () -> Void
    ) {
        self.ashFileURL = ashFileURL
        self.component = component
        self.demoAppGenerator = demoAppGenerator
        self.document = document
        self.packageNameProvider = packageNameProvider
        self.pbxProjectSyncer = pbxProjectSyncer
        self.presenter = presenter
        self.cancelAction = cancelAction
    }
    
    func onGenerate() {
        guard let url = openFolderSelection()
        else { return }
        generate(at: url)
    }
    
    func generate(at url: URL) {
        let allFamilies: [Family] = document.families.map { $0.family }
        guard let family = allFamilies.first(where: { $0.name == component.name.family })
        else { return }
        do {
            let name = packageNameProvider.packageName(
                forComponentName: component.name,
                of: family,
                packageConfiguration: PackageConfiguration(name: "", appendPackageName: false, hasTests: false)
            ) + "Demo"
            
            let result = try demoAppGenerator.generateDemoApp(named: name,
                                                                 at: url)
            print("Generated at: \(result)")
            
            try pbxProjectSyncer.sync(document: document,
                                      at: ashFileURL,
                                      withProjectAt: result.xcodeProjURL)
        } catch {
            print("Error: \(error)")
        }

    }
    
    func onAppear() {
        presenter.startLoadingList()
        
        let dependencies = component.localDependencies
            .map { dependency in
                DemoAppDependencyViewModel(
                    title: dependency.name.full,
                    targetTypesSelected: dependency.targetTypes.reduce(into: [DemoAppDependencyTargetTypeSelection](), { $0.append(.init(targetType: $1.value, isSelected: true)) })
                )
            }
        presenter.update(dependencies: dependencies)
        
        presenter.stopLoadingList()
    }
    
    func onCancel() {
        cancelAction()
    }
    
    // MARK: - Private
    private func openFolderSelection() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = ashFileURL
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = true
        openPanel.allowedContentTypes = []
        
        openPanel.runModal()
        return openPanel.url
    }

}
