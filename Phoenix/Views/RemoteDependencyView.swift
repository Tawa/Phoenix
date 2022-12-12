import Component
import SwiftPackage
import SwiftUI

struct RemoteDependencyView: View {
    @Binding var dependency: RemoteDependency

    let allVersionsTypes: [IdentifiableWithTitle<ExternalDependencyVersion>] = [
        .init(title: "branch", value: ExternalDependencyVersion.branch(name: "main")),
        .init(title: "exact", value: ExternalDependencyVersion.exact(version: "1.0.0")),
        .init(title: "from", value: ExternalDependencyVersion.from(version: "1.0.0"))
    ]
    
    let allDependencyTypes: [IdentifiableWithSubtype<PackageTargetType>]

    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("URL:")
                TextField("url", text: $dependency.url)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: onRemove) { Image(systemName: "trash") }
            }
            HStack {
                Menu {
                    Button("Name") {
                        dependency.name = .name(dependency.nameText)
                    }
                    Button("Name/Package") {
                        dependency.name = .product(name: dependency.nameText, package: "")
                    }
                } label: {
                    switch dependency.name {
                    case .name:
                        Text("Name")
                    case .product:
                        Text("Name/Package")
                    }
                }
                .frame(width: 150)
            }
            switch dependency.name {
            case .name:
                TextField("Name", text: $dependency.nameText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            case .product:
                TextField("Name", text: $dependency.nameText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Package", text: $dependency.packageText.nonOptionalBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                Menu {
                    ForEach(allVersionsTypes) { versionType in
                        Button(versionType.title) { dependency.version = versionType.value }
                    }
                } label: {
                    Text(dependency.version.title)
                }
                .frame(width: 100)
                TextField(versionPlaceholder,
                          text: .init(get: { dependency.versionText },
                                      set: { dependency.versionText = $0 }))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                    .frame(maxWidth: .infinity)
            }
            VStack {
                ForEach(allDependencyTypes) { dependencyType in
                    HStack {
                        Toggle(isOn: .init(get: { dependency.targetTypes.contains(where: { dependencyType.value == $0 }) },
                                           set: {
                            if $0 {
                                dependency.targetTypes.append(dependencyType.value)
                            } else {
                                dependency.targetTypes.removeAll(where: { $0 == dependencyType.value })
                            }
                        })) {
                            Text(dependencyType.title)
                        }
                        if let subtitle = dependencyType.subtitle, let subvalue = dependencyType.subValue {
                            Toggle(isOn: .init(get: { dependency.targetTypes.contains(where: { subvalue == $0 }) },
                                               set: {
                                if $0 {
                                    dependency.targetTypes.append(subvalue)
                                } else {
                                    dependency.targetTypes.removeAll(where: { $0 == subvalue })
                                }
                            })) {
                                Text(subtitle)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Private
    private var versionPlaceholder: String {
        switch dependency.version {
        case .from, .exact:
            return "1.0.0"
        case .branch:
            return "main"
        }
    }
}
