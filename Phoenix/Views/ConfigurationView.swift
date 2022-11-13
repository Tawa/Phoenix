import AccessibilityIdentifiers
import Combine
import Component
import Factory
import SwiftUI

class ConfigurationViewData: ObservableObject {
    @Published var configuration: ProjectConfiguration
    
    init(configuration: ProjectConfiguration) {
        self.configuration = configuration
    }
}

class ConfigurationViewInteractor {
    let getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol
    let updateProjectConfigurationUseCase: UpdateProjectConfigurationUseCaseProtocol

    var viewData: ConfigurationViewData
    var subscription: AnyCancellable?
    
    init(getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol,
         updateProjectConfigurationUseCase: UpdateProjectConfigurationUseCaseProtocol) {
        self.viewData = .init(configuration: getProjectConfigurationUseCase.value)
        self.getProjectConfigurationUseCase = getProjectConfigurationUseCase
        self.updateProjectConfigurationUseCase = updateProjectConfigurationUseCase
        
        subscription = getProjectConfigurationUseCase
            .publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] projectConfiguration in
                self?.viewData.configuration = projectConfiguration
            })
    }
    
    func update(configuration: ProjectConfiguration) {
        updateProjectConfigurationUseCase.update(configuration: configuration)
    }
}

struct ConfigurationView: View {
    @ObservedObject var viewData: ConfigurationViewData
    let interactor: ConfigurationViewInteractor
    private var configuration: ProjectConfiguration { viewData.configuration }
    let columnWidth: CGFloat = 200
    let narrowColumnWidth: CGFloat = 100
    let rowHeight: CGFloat = 30
    let allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
    let onDismiss: () -> Void
    
    @FocusState private var focusedName: Int?
    
    init(interactor: ConfigurationViewInteractor,
         allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>],
         onDismiss: @escaping () -> Void,
         focusedName: Int? = nil) {
        self.interactor = interactor
        self.viewData = interactor.viewData
        self.allDependenciesConfiguration = allDependenciesConfiguration
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
            ForEach(0..<viewData.configuration.packageConfigurations.count, id: \.self) { index in
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
                              text: Binding(get: {
                        viewData.configuration.swiftVersion
                    }, set: {
                        var configuration = interactor.viewData.configuration
                        configuration.swiftVersion = $0
                        interactor.update(configuration: configuration)
                    }))
                }
                HStack {
                    Text("Demo Apps Default Organization Identifier")
                    TextField("com.myorganization.demoapp", text: Binding(get: {
                        configuration.defaultOrganizationIdentifier ?? ""
                    }, set: { newValue in
                        var configuration = interactor.viewData.configuration
                        configuration.defaultOrganizationIdentifier = newValue.isEmpty ? nil : newValue
                        interactor.update(configuration: configuration)
                    }))
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
                                  text: Binding(get: {
                            viewData.configuration.packageConfigurations[index].name
                        }, set: {
                            var configuration = interactor.viewData.configuration
                            configuration.packageConfigurations[index].name = $0
                            interactor.update(configuration: configuration)
                        }))
                        .focused($focusedName, equals: index)
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
                                  text: .init(get: { configuration.packageConfigurations[index].containerFolderName ?? "" },
                                              set: {
                            var configuration = interactor.viewData.configuration
                            configuration.packageConfigurations[index].containerFolderName = $0.isEmpty ? nil : $0
                            interactor.update(configuration: configuration)
                        }))
                        .with(accessibilityIdentifier: ConfigurationSheetIdentifiers.textField(column: 1, row: index))
                    }
                    columnView(width: narrowColumnWidth) {
                        Text("Append Name")
                    } content: { index in
                        Toggle("",
                               isOn: Binding(get: {
                            viewData.configuration.packageConfigurations[index].appendPackageName
                        }, set: {
                            var configuration = interactor.viewData.configuration
                            configuration.packageConfigurations[index].appendPackageName = $0
                            interactor.update(configuration: configuration)
                        }))
                    }
                    columnView(width: narrowColumnWidth) {
                        Text("Has Test")
                    } content: { index in
                        Toggle("",
                               isOn: Binding(get: {
                            viewData.configuration.packageConfigurations[index].hasTests
                        }, set: {
                            var configuration = interactor.viewData.configuration
                            configuration.packageConfigurations[index].hasTests = $0
                            interactor.update(configuration: configuration)
                        }))
                    }
                    columnView(width: columnWidth) {
                        HStack {
                            Text("Internal Dependency")
                            Spacer()
                        }
                    } content: { index in
                        TextField("Dependency Name",
                                  text: .init(get: { configuration.packageConfigurations[index].internalDependency ?? "" },
                                              set: {
                            var configuration = interactor.viewData.configuration
                            configuration.packageConfigurations[index].internalDependency = $0.isEmpty ? nil : $0
                            interactor.update(configuration: configuration)
                        }))
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
                    DependencyView<PackageTargetType, String>(
                        title: "Default Dependencies",
                        allTypes: allDependenciesConfiguration,
                        allSelectionValues: configuration.packageConfigurations.map(\.name),
                        onUpdateTargetTypeValue: { packageTargetType, value in
                            var configuration = interactor.viewData.configuration
                            configuration.defaultDependencies[packageTargetType] = value
                            interactor.update(configuration: configuration)
                        })
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
            var configuration = interactor.viewData.configuration
            configuration.packageConfigurations.sort(by: { $0.name < $1.name })
            interactor.update(configuration: configuration)
        }
    }
                        
    private func removePackageConfiguration(at index: Int) {
        var configuration = interactor.viewData.configuration
        configuration.packageConfigurations.remove(at: index)
        interactor.update(configuration: configuration)
    }
    
    private func onAddNew() {
        var configuration = interactor.viewData.configuration
        configuration.packageConfigurations.append(.init(name: "Name",
                                                         containerFolderName: nil,
                                                         appendPackageName: true,
                                                         internalDependency: nil,
                                                         hasTests: false))
        interactor.update(configuration: configuration)
    }
}

