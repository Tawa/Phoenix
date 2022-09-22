import Component
import SwiftUI

struct ConfigurationView: View {
    @Binding var configuration: ProjectConfiguration
    let columnWidth: CGFloat = 200
    let narrowColumnWidth: CGFloat = 100
    let rowHeight: CGFloat = 50
    let onDismiss: () -> Void
    
    @FocusState private var focusedName: Int?
    
    @ViewBuilder
    func columnView<RowContent: View>(title: String, width: CGFloat? = nil, content: @escaping (Int) -> RowContent) -> some View {
        VStack(alignment: .center) {
            Text(title)
                .frame(height: rowHeight * 0.5)
            ForEach(0..<configuration.packageConfigurations.count, id: \.self) { index in
                content(index)
                    .frame(height: rowHeight)
            }
        }.frame(width: width)
    }
    
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
                    columnView(title: "Name") { index in
                        TextField("Name",
                                  text: $configuration.packageConfigurations[index].name)
                        .focused($focusedName, equals: index)
                        .onChange(of: focusedName, perform: { newValue in
                            withAnimation {
                                configuration.packageConfigurations.sort(by: { $0.name < $1.name })
                            }
                        })
                        .font(.title)
                    }.frame(minWidth: columnWidth)
                    columnView(title: "Folder", width: columnWidth) { index in
                        TextField("Folder Name",
                                  text: .init(get: { configuration.packageConfigurations[index].containerFolderName ?? "" },
                                              set: { configuration.packageConfigurations[index].containerFolderName = $0.isEmpty ? nil : $0 }))
                        .font(.title)
                    }
                    columnView(title: "Append Name?", width: narrowColumnWidth) { index in
                        Toggle("", isOn: $configuration.packageConfigurations[index].appendPackageName)
                    }
                    columnView(title: "Has Tests?", width: narrowColumnWidth) { index in
                        Toggle("", isOn: $configuration.packageConfigurations[index].hasTests)
                    }
                    columnView(title: "Internal Dependency", width: columnWidth) { index in
                        TextField("Dependency Name",
                                  text: .init(get: { configuration.packageConfigurations[index].internalDependency ?? "" },
                                              set: { configuration.packageConfigurations[index].internalDependency = $0.isEmpty ? nil : $0 }))
                        .font(.title)
                    }
                    columnView(title: "", width: narrowColumnWidth) { index in
                        Button(action: { removePackageConfiguration(at: index) }) {
                            Image(systemName: "trash")
                                .padding()
                        }
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
                }.keyboardShortcut(.cancelAction)
            }.padding()
        }
        .frame(minHeight: 500)
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
