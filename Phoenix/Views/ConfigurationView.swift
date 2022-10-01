import Component
import SwiftUI

struct ConfigurationView: View {
    @Binding var configuration: ProjectConfiguration
    let columnWidth: CGFloat = 200
    let narrowColumnWidth: CGFloat = 80
    let rowHeight: CGFloat = 50
    let onDismiss: () -> Void
    
    @FocusState private var focusedName: Int?
    
    @ViewBuilder
    func columnView<HeaderContent: View, RowContent: View>(
        width: CGFloat? = nil,
        header: @escaping () -> HeaderContent,
        content: @escaping (Int) -> RowContent)
    -> some View {
        VStack(alignment: .center, spacing: 0) {
            header()
                .frame(height: rowHeight * 0.5)
            ForEach(0..<configuration.packageConfigurations.count, id: \.self) { index in
                content(index)
                    .frame(height: rowHeight)
            }
        }.frame(width: width)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                Text("Project Configuration")
                    .font(.largeTitle)
                Divider()
                HStack {
                    Text("Swift Version")
                    TextField("default: \(ProjectConfiguration.default.swiftVersion)", text: $configuration.swiftVersion)
                }.font(.title)
                HStack {
                    Text("Demo Apps Default Organization Identifier")
                    TextField("com.myorganization.demoapp", text: Binding(get: {
                        configuration.defaultOrganizationIdentifier ?? ""
                    }, set: { newValue in
                        configuration.defaultOrganizationIdentifier = newValue.isEmpty ? nil : newValue
                    }))
                }.font(.title)
                Divider()
                HStack(spacing: 8) {
                    columnView {
                        HStack {
                            Text("Name")
                                .font(.title.bold())
                            Spacer()
                        }
                    } content: { index in
                        TextField("Name",
                                  text: $configuration.packageConfigurations[index].name)
                        .focused($focusedName, equals: index)
                        .font(.title)
                    }.frame(minWidth: columnWidth)
                    columnView(width: columnWidth) {
                        HStack {
                            Text("Folder")
                                .font(.title.bold())
                            Spacer()
                        }
                    } content: { index in
                        TextField("Folder Name",
                                  text: .init(get: { configuration.packageConfigurations[index].containerFolderName ?? "" },
                                              set: { configuration.packageConfigurations[index].containerFolderName = $0.isEmpty ? nil : $0 }))
                        .font(.title)
                    }
                    columnView(width: narrowColumnWidth) {
                        Text("Append Name")
                            .font(.subheadline.bold())
                    } content: { index in
                        Toggle("", isOn: $configuration.packageConfigurations[index].appendPackageName)
                    }
                    columnView(width: narrowColumnWidth) {
                        Text("Has Test")
                            .font(.subheadline.bold())
                    } content: { index in
                        Toggle("", isOn: $configuration.packageConfigurations[index].hasTests)
                    }
                    columnView(width: columnWidth) {
                        HStack {
                            Text("Internal Dependency")
                                .font(.subheadline.bold())
                            Spacer()
                        }
                    } content: { index in
                        TextField("Dependency Name",
                                  text: .init(get: { configuration.packageConfigurations[index].internalDependency ?? "" },
                                              set: { configuration.packageConfigurations[index].internalDependency = $0.isEmpty ? nil : $0 }))
                        .font(.title)
                    }
                    columnView {
                        Text("")
                    } content: { index in
                        Button(action: { removePackageConfiguration(at: index) }) {
                            Image(systemName: "trash")
                                .padding()
                        }
                    }
                }
                HStack {
                    Button(action: onAddNew) {
                        Text("Add New")
                    }
                    Button(action: onDismiss) {
                        Text("Close")
                    }.keyboardShortcut(.cancelAction)
                }.padding()
            }.padding()
        }
        .onDisappear { configuration.packageConfigurations.sort(by: { $0.name < $1.name }) }
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
