import SwiftUI
import Package

struct ConfigurationView: View {
    @Binding var configuration: ProjectConfiguration
    let columnWidth: CGFloat = 200
    let narrowColumnWidth: CGFloat = 100
    let onDismiss: () -> Void
    
    @FocusState private var focusedName: Int?
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: true) {
                Text("Project Configuration")
                    .font(.largeTitle)
                Divider()
                HStack {
                    Text("Swift Version")
                    TextField("default: \(ProjectConfiguration.default.swiftVersion)", text: $configuration.swiftVersion)
                }.font(.title)
//                HStack {
//                    Text("Demo Apps Default Organization Identifier")
//                    TextField("com.myorganization.demoapp", text: Binding(get: {
//                        configuration.defaultOrganizationIdentifier ?? ""
//                    }, set: { newValue in
//                        configuration.defaultOrganizationIdentifier = newValue.isEmpty ? nil : newValue
//                    }))
//                }.font(.title)
                Divider()
                HStack(spacing: 0) {
                    Text("Name")
                        .font(.title)
                        .frame(minWidth: columnWidth)
                    Text("Folder")
                        .font(.title)
                        .frame(width: columnWidth)
                    Text("Append Name?")
                        .frame(width: narrowColumnWidth)
                    Text("Has Tests?")
                        .frame(width: narrowColumnWidth)
                    Text("Internal Dependency")
                        .font(.title)
                        .frame(width: columnWidth)
                }
                ForEach(0..<configuration.packageConfigurations.count, id: \.self) { index in
                    HStack(spacing: 0) {
                        TextField("Name",
                                  text: $configuration.packageConfigurations[index].name)
                        .focused($focusedName, equals: index)
                        .onChange(of: focusedName, perform: { newValue in
                            configuration.packageConfigurations.sort(by: { $0.name < $1.name })
                        })
                        .font(.title)
                        .frame(minWidth: columnWidth)
                        TextField("Folder Name",
                                  text: .init(get: { configuration.packageConfigurations[index].containerFolderName ?? "" },
                                              set: { configuration.packageConfigurations[index].containerFolderName = $0.isEmpty ? nil : $0 }))
                        .font(.title)
                        .frame(width: columnWidth)
                        Toggle("", isOn: $configuration.packageConfigurations[index].appendPackageName)
                            .frame(width: narrowColumnWidth)
                        Toggle("", isOn: $configuration.packageConfigurations[index].hasTests)
                            .frame(width: narrowColumnWidth)
                        TextField("Dependency Name",
                                  text: .init(get: { configuration.packageConfigurations[index].internalDependency ?? "" },
                                              set: { configuration.packageConfigurations[index].internalDependency = $0.isEmpty ? nil : $0 }))
                        .font(.title)
                        .frame(width: columnWidth)
                        Button(action: { removePackageConfiguration(at: index) }) {
                            Image(systemName: "trash")
                                .padding()
                        }.padding(.horizontal)
                    }
                }
            }
            .padding()
            HStack {
                Button(action: onAddNew) {
                    Text("Add New")
                }
                Button(action: onDismiss) {
                    Text("Close")
                }
            }.padding()
        }
        .onExitCommand(perform: onDismiss)
    }
    
    private func removePackageConfiguration(at index: Int) {
        configuration.packageConfigurations.remove(at: index)
    }
    
    private func onAddNew() {
        configuration.packageConfigurations.append(.init(name: "Name",
                                                         containerFolderName: nil,
                                                         appendPackageName: true,
                                                         internalDependency: nil,
                                                         hasTests: false))
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView(configuration: .constant(.default), onDismiss: {})
    }
}
