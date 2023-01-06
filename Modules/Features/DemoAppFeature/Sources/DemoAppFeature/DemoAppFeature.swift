import ComponentDetailsProviderContract
import DemoAppGeneratorContract
import PBXProjectSyncerContract
import PhoenixDocument
import SwiftUI

public struct DemoAppFeatureInput: Identifiable {
    public let id: String = UUID().uuidString
    let component: Component
    let document: PhoenixDocument
    let ashFileURL: URL
    let onDismiss: () -> Void
    let onError: (Error) -> Void
    
    public init(
        component: Component,
        document: PhoenixDocument,
        ashFileURL: URL,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) {
        self.component = component
        self.document = document
        self.ashFileURL = ashFileURL
        self.onDismiss = onDismiss
        self.onError = onError
    }
    
}
public struct DemoAppFeatureView: View {
    @StateObject private var viewModel: DemoAppFeatureViewModel
    let dependency: Dependency
    let interactor: DemoAppFeatureInteractor
    
    public init(data: DemoAppFeatureInput,
                dependency: Dependency) {
        self.dependency = dependency
        
        let viewModel = DemoAppFeatureViewModel(
            title: dependency.demoAppNameProvider.demoAppName(
                for: data.component,
                family: data.document.families.first(where: { $0.family.name == data.component.name.family })?.family ?? .init(name: "")
            ),
            organizationIdentifier: data.document.projectConfiguration.defaultOrganizationIdentifier ?? ""
        )
        
        let presenter = DemoAppFeaturePresenter(viewModel: viewModel)
        
        interactor = DemoAppFeatureInteractor(
            ashFileURL: data.ashFileURL,
            component: data.component,
            document: data.document,
            packageFolderNameProvider: dependency.packageFolderNameProvider,
            packageNameProvider: dependency.packageNameProvider,
            pbxProjectSyncer: dependency.pbxProjectSyncer,
            presenter: presenter,
            demoAppGenerator: dependency.demoAppGenerator,
            cancelAction: data.onDismiss,
            onError: data.onError
        )
        
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0)  {
                HStack {
                    Text("Include Components:")
                        .font(.title)
                }.padding()
                ZStack {
                    Color.gray.opacity(0.1)
                    componentsList
                        .padding()
                    if viewModel.isListLoading {
                        ProgressView()
                    }
                }
                .frame(minWidth: 400)
                .padding([.leading, .bottom, .trailing])
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.title)
                    .font(.title.bold())
                    .padding([.top, .bottom])
                Text("Organization Identifier")
                    .font(.title)
                    .padding(2)
                TextField("i,e: com.myorganization.demo", text: $viewModel.organizationIdentifier)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title)
                Spacer()
                HStack {
                    Spacer()
                    Button(action: interactor.onGenerate) {
                        Text("Generate")
                    }
                    Button(action: interactor.onCancel) {
                        Text("Cancel")
                    }.keyboardShortcut(.cancelAction)
                }.padding()
            }.padding(.trailing)
        }
        .frame(minWidth: 1000, minHeight: 600)
        .onAppear(perform: interactor.onAppear)
    }
    
    private var componentsList: some View {
        DemoAppDependencyList(sections: viewModel.dependencySections)
    }
}

extension DemoAppFeatureView {
    public struct Dependency {
        let demoAppGenerator: DemoAppGeneratorProtocol
        let demoAppNameProvider: DemoAppNameProviderProtocol
        let packageFolderNameProvider: PackageFolderNameProviderProtocol
        let packageNameProvider: PackageNameProviderProtocol
        let pbxProjectSyncer: PBXProjectSyncerProtocol
        
        public init(
            demoAppGenerator: DemoAppGeneratorProtocol,
            demoAppNameProvider: DemoAppNameProviderProtocol,
            packageFolderNameProvider: PackageFolderNameProviderProtocol,
            packageNameProvider: PackageNameProviderProtocol,
            pbxProjectSyncer: PBXProjectSyncerProtocol
        ) {
            self.demoAppGenerator = demoAppGenerator
            self.demoAppNameProvider = demoAppNameProvider
            self.packageFolderNameProvider = packageFolderNameProvider
            self.packageNameProvider = packageNameProvider
            self.pbxProjectSyncer = pbxProjectSyncer
        }
    }
}
