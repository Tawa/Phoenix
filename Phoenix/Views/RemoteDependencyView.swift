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
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(dependency.name.name)
                    .bold()
                Button(action: onRemove) { Image(systemName: "trash") }
            }
            Text(dependency.url)

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
            VStack(spacing: 0) {
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
