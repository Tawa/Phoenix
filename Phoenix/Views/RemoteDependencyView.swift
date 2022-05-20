import SwiftUI

struct IdentifiableWithSubtype<ValueType>: Identifiable where ValueType: Identifiable {
    var id: ValueType.ID { value.id }
    let title: String
    let subtitle: String?
    let value: ValueType
    let subValue: ValueType?
}

struct IdentifiableWithTitle<Data>: Identifiable where Data: Identifiable {
    var id: Data.ID { value.id }
    let title: String
    let value: Data
}

struct RemoteDependencyView<DependencyType, VersionType>: View
where DependencyType: Identifiable,
      DependencyType: Equatable,
        VersionType: Identifiable {
    let name: String
    let urlString: String

    let allVersionsTypes: [IdentifiableWithTitle<VersionType>]
    let onSubmitVersionType: (VersionType) -> Void
    let versionPlaceholder: String
    let versionTitle: String
    let versionText: String
    let onSubmitVersionText: (String) -> Void

    let allDependencyTypes: [IdentifiableWithSubtype<DependencyType>]
    let dependencyTypes: [DependencyType]
    let enabledTypes: [DependencyType]
    let onUpdateDependencyType: (DependencyType, Bool) -> Void

    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(name)
                    .font(.largeTitle)
                Button(action: onRemove) { Text("Remove") }
                Spacer()
            }
            Text(urlString)
                .font(.title)

            HStack {
                Menu {
                    ForEach(allVersionsTypes) { versionType in
                        Button(versionType.title) { onSubmitVersionType(versionType.value) }
                    }
                } label: {
                    Text(versionTitle)
                }
                .frame(width: 150)
                LazySubmitTextField(placeholder: versionPlaceholder,
                                    initialValue: versionText,
                                    onSubmit: onSubmitVersionText)
                Spacer()
            }

            HStack(alignment: .top) {
                ForEach(allDependencyTypes.filter { allType in
                    dependencyTypes.contains(where: { allType.value.id == $0.id })
                }) { dependencyType in
                    VStack(alignment: .leading) {
                        Toggle(isOn: .init(get: { enabledTypes.contains(where: { dependencyType.value == $0 }) },
                                           set: { onUpdateDependencyType(dependencyType.value, $0) })) {
                            Text(dependencyType.title)
                        }
                        if let subtitle = dependencyType.subtitle, let subvalue = dependencyType.subValue {
                            Toggle(isOn: .init(get: { enabledTypes.contains(where: { subvalue == $0 }) },
                                               set: { onUpdateDependencyType(subvalue, $0) })) {
                                Text(subtitle)
                            }
                        }
                    }
                }
            }

        }
        .padding()
    }
}

struct RemoteDependencyView_Previews: PreviewProvider {
    enum DependencyTypeMock: Hashable, Identifiable {
        var id: Int { hashValue }

        case contract
        case implementation
        case tests
        case mocks
    }

    enum VersionTypeMock: Hashable, Identifiable {
        var id: Int { hashValue }

        case branch
        case version
    }

    static var previews: some View {
        RemoteDependencyView(name: "Name",
                             urlString: "github.com",
                             allVersionsTypes: [
                                .init(title: "branch", value: VersionTypeMock.branch),
                                .init(title: "from", value: VersionTypeMock.version)
                             ],
                             onSubmitVersionType: { _ in },
                             versionPlaceholder: "1.0.0",
                             versionTitle: "from",
                             versionText: "1.5.0",
                             onSubmitVersionText: { _ in },
                             allDependencyTypes: [
                                .init(title: "Contract", subtitle: nil, value: DependencyTypeMock.contract, subValue: nil),
                                .init(title: "Implementation", subtitle: "Tests", value: DependencyTypeMock.implementation, subValue: .tests),
                                .init(title: "Mock", subtitle: nil, value: DependencyTypeMock.mocks, subValue: nil),
                             ],
                             dependencyTypes: [.contract, .implementation],
                             enabledTypes: [.implementation, .tests],
                             onUpdateDependencyType: { _ , _ in},
                             onRemove: { })
    }
}
