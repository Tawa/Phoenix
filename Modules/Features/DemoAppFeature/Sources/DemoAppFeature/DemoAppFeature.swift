import Package
import SwiftUI
import PhoenixDocument

public struct DemoAppDependency: Identifiable {
    public var id = UUID().uuidString
    
    let title: String
    let isSelected: Bool
}

public struct DemoAppFeatureData: Identifiable {
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

extension DemoAppFeatureView {
    public struct Dependency {
        public init() {
            
        }
    }
}

struct DemoAppInteractor {
    let cancelAction: () -> Void
    
    
    func onGenerate() {
        
    }
    
    func onCancel() {
        cancelAction()
    }
}

public struct DemoAppFeatureView: View {
    let data: DemoAppFeatureData
    let dependency: Dependency
    let interactor: DemoAppInteractor
    @State private var organizationIdentifier: String = ""

    public init(data: DemoAppFeatureData,
                dependency: Dependency) {
        self.data = data
        self.dependency = dependency
        
        interactor = DemoAppInteractor(
            cancelAction: data.onDismiss
        )
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0)  {
                HStack {
                    Text("Include Components:")
                        .font(.title)
                }.padding()
                ScrollView {
//                    ForEach(viewModel.dependencies) { dependency in
//                        HStack {
//                            Toggle(dependency.title, isOn: .constant(dependency.isSelected))
//                            Spacer()
//                        }
//                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .padding([.leading, .bottom, .trailing])
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("\(data.component.name.full)DemoApp")
                    .font(.title.bold())
                    .padding([.top, .bottom])
                Text("Organization Identifier")
                    .padding(2)
//                TextField("default: \(viewModel.defaultOrganizationIdentifier)", text: $organizationIdentifier)
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
        }.frame(minWidth: 1000, minHeight: 600)
    }
}
