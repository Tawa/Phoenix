import SwiftUI

public struct DemoAppDependency: Identifiable {
    public var id = UUID().uuidString
    
    let title: String
    let isSelected: Bool
}

public struct GenerateDemoAppPopoverViewModel {
    let componentName: String
    let dependencies: [DemoAppDependency]
    let defaultOrganizationIdentifier: String
    let onGenerate: () -> Void
    let onDismiss: () -> Void
}

struct GenerateDemoAppPopoverView: View {
    let viewModel: GenerateDemoAppPopoverViewModel
    @State private var organizationIdentifier: String = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0)  {
                HStack {
                    Text("Include Components:")
                        .font(.title)
                }.padding()
                ScrollView {
                    ForEach(viewModel.dependencies) { dependency in
                        HStack {
                            Toggle(dependency.title, isOn: .constant(dependency.isSelected))
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .padding([.leading, .bottom, .trailing])
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("\(viewModel.componentName)DemoApp")
                    .font(.title.bold())
                    .padding([.top, .bottom])
                Text("Organization Identifier")
                    .padding(2)
                TextField("default: \(viewModel.defaultOrganizationIdentifier)", text: $organizationIdentifier)
                Spacer()
                HStack {
                    Spacer()
                    Button(action: viewModel.onGenerate) {
                        Text("Generate")
                    }
                    Button(action: viewModel.onDismiss) {
                        Text("Cancel")
                    }
                }.padding()
            }.padding(.trailing)
        }
    }
}

struct GenerateDemoAppPopoverView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateDemoAppPopoverView(
            viewModel: .init(
                componentName: "HomeFeature",
                dependencies: [
                    .init(title: "HomeUseCasesContract", isSelected: true),
                    .init(title: "HomeUseCases", isSelected: true),
                    .init(title: "HomeUseCasesMock", isSelected: true),
                ],
                defaultOrganizationIdentifier: "com.myorganization.app",
                onGenerate: {},
                onDismiss: {})
        )
    }
}
