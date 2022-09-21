import Component
import PhoenixDocument
import SwiftUI

public struct DemoAppFeatureInput: Identifiable {
    public let id: String = UUID().uuidString
    let component: Component
    let document: PhoenixDocument
    let ashFileURL: URL
    let onDismiss: () -> Void
    
    public init(
        component: Component,
        document: PhoenixDocument,
        ashFileURL: URL,
        onDismiss: @escaping () -> Void
    ) {
        self.component = component
        self.document = document
        self.ashFileURL = ashFileURL
        self.onDismiss = onDismiss
    }
    
}
public struct DemoAppFeatureView: View {
    @ObservedObject private var viewModel: DemoAppFeatureViewModel
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
            component: data.component,
            document: data.document,
            presenter: presenter,
            cancelAction: data.onDismiss
        )
        
        self.viewModel = viewModel
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0)  {
                HStack {
                    Text("Include Components:")
                        .font(.title)
                }.padding()
                ZStack {
                    DemoAppDependencyList(dependencies: viewModel.dependencies)
                    if viewModel.isListLoading {
                        ProgressView()
                    }
                }
                .padding()
                .frame(minWidth: 400)
                .background(Color.gray.opacity(0.1))
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
                    .font(.title)
                Spacer()
                HStack {
                    Spacer()
                    Button(action: interactor.onGenerate) {
                        Text("Generate")
                    }
                    Button(action: interactor.onCancel) {
                        Text("Cancel")
                    }
                }.padding()
            }.padding(.trailing)
        }
        .frame(minWidth: 1000, minHeight: 600)
        .onAppear(perform: interactor.onAppear)
        .onExitCommand(perform: interactor.onCancel)
    }
}

extension DemoAppFeatureView {
    public struct Dependency {
        let demoAppNameProvider: DemoAppNameProviderProtocol
        
        public init(
            demoAppNameProvider: DemoAppNameProviderProtocol
        ) {
            self.demoAppNameProvider = demoAppNameProvider
        }
    }
}
