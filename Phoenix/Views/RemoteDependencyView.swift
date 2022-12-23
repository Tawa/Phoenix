import Component
import SwiftPackage
import SwiftUI

struct RemoteDependencyView: View {
    @Binding var dependency: RemoteDependency
    
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
            ExternalDependencyVersionView(version: $dependency.version)
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
}
