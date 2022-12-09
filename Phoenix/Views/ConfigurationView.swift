import AccessibilityIdentifiers
import Combine
import Component
import Factory
import SwiftUI

struct ConfigurationView: View {
    @Binding var configuration: ProjectConfiguration
    let relationViewData: RelationViewData
    let columnWidth: CGFloat = 200
    let narrowColumnWidth: CGFloat = 100
    let rowHeight: CGFloat = 30
    let onDismiss: () -> Void
    
    @FocusState private var focusedName: Int?
    
    init(
        configuration: Binding<ProjectConfiguration>,
        relationViewData: RelationViewData,
        onDismiss: @escaping () -> Void,
        focusedName: Int? = nil) {
            self._configuration = configuration
            self.relationViewData = relationViewData
            self.onDismiss = onDismiss
            self.focusedName = focusedName
        }
    
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
            VStack(alignment: .leading) {
                Text("Project Configuration")
                    .font(.largeTitle)
                Divider()
                HStack {
                    Text("Swift Version")
                    TextField("default: \(ProjectConfiguration.default.swiftVersion)",
                              text: $configuration.swiftVersion)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack {
                    Text("Demo Apps Default Organization Identifier")
                    TextField("com.myorganization.demoapp", text: $configuration.defaultOrganizationIdentifier.nonOptionalBinding)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Divider()
                HStack(spacing: 8) {
                    columnView {
                        HStack {
                            Text("Name")
                                .bold()
                            Spacer()
                        }
                    } content: { index in
                        TextField("Name",
                                  text: $configuration.packageConfigurations[index].name)
                        .focused($focusedName, equals: index)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .with(accessibilityIdentifier: ConfigurationSheetIdentifiers.textField(column: 0, row: index))
                    }.frame(minWidth: columnWidth)
                    columnView(width: columnWidth) {
                        HStack {
                            Text("Folder")
                                .bold()
                            Spacer()
                        }
                    } content: { index in
                        TextField("Folder Name",
                                  text: $configuration.packageConfigurations[index].containerFolderName.nonOptionalBinding)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .with(accessibilityIdentifier: ConfigurationSheetIdentifiers.textField(column: 1, row: index))
                    }
                    columnView(width: narrowColumnWidth) {
                        Text("Append Name")
                    } content: { index in
                        Toggle("", isOn: $configuration.packageConfigurations[index].appendPackageName)
                    }
                    columnView(width: narrowColumnWidth) {
                        Text("Has Test")
                    } content: { index in
                        Toggle("", isOn: $configuration.packageConfigurations[index].hasTests)
                    }
                    columnView(width: columnWidth) {
                        HStack {
                            Text("Internal Dependency")
                            Spacer()
                        }
                    } content: { index in
                        TextField("Dependency Name",
                                  text: $configuration.packageConfigurations[index].internalDependency.nonOptionalBinding)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .with(accessibilityIdentifier: ConfigurationSheetIdentifiers.textField(column: 2, row: index))
                    }
                    columnView {
                        Text("")
                    } content: { index in
                        Button(action: { removePackageConfiguration(at: index) }) {
                            Image(systemName: "trash")
                                .padding()
                        }
                    }
                }.padding()
                Button(action: onAddNew) {
                    Text("Add New Package")
                }.padding(.horizontal)
                    .with(accessibilityIdentifier: ConfigurationSheetIdentifiers.addNewButton)
                if configuration.packageConfigurations.count > 1 {
                    RelationView(
                        defaultDependencies: $configuration.defaultDependencies,
                        projectConfiguration: configuration,
                        title: "Default Dependencies",
                        viewData: relationViewData
                    )
                }
                Button(action: onDismiss) {
                    Text("Close")
                }.padding(.horizontal)
                    .keyboardShortcut(.cancelAction)
                    .with(accessibilityIdentifier: ConfigurationSheetIdentifiers.closeButton)
                Spacer()
            }.padding()
        }
        .onDisappear {
            configuration.packageConfigurations.sort(by: { $0.name < $1.name })
        }
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

