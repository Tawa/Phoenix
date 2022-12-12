import Component
import SwiftUI
import SwiftPackage

struct ResourcesView: View {
    @Binding var resources: [ComponentResources]
    @State private var newFieldValue: String = ""
    let allTargetTypes: [IdentifiableWithSubtype<PackageTargetType>]
    
    private let newValuePlaceholder: String = "Resources"
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach($resources) { $resource in
                HStack {
                    Divider()
                    VStack(alignment: .leading) {
                        HStack {
                            CustomMenu(title: String(describing: resource.type),
                                       data: [TargetResources.ResourcesType.copy,
                                              TargetResources.ResourcesType.process],
                                       onSelection: { resource.type = $0 },
                                       hasRemove: true,
                                       onRemove: {  })
                            .frame(width: 150)
                            TextField("Folder Name", text: $resource.folderName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 150)
                                .id(resource.id)
                            Button(action: {
                                resources.removeAll(where: { resource == $0 })
                            }) {
                                Image(systemName: "trash")
                            }
                        }
                        ForEach(allTargetTypes) { targetType in
                            HStack {
                                Toggle(
                                    isOn: Binding(
                                        get: { resource.targets.contains(where: { $0 == targetType.value }) },
                                        set: {
                                            if $0 {
                                                resource.targets.append(targetType.value)
                                            } else {
                                                resource.targets.removeAll(where: { $0 == targetType.value })
                                            }
                                        })) {
                                            Text(targetType.title)
                                        }
                                if let subtitle = targetType.subtitle, let subValue = targetType.subValue {
                                    Toggle(
                                        isOn: Binding(
                                            get: { resource.targets.contains(where: { $0 == subValue }) },
                                            set: {
                                                if $0 {
                                                    resource.targets.append(subValue)
                                                } else {
                                                    resource.targets.removeAll(where: { $0 == subValue })
                                                }
                                            })) {
                                                Text(subtitle)
                                            }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            HStack {
                Button(action: {
                    let folderName = newFieldValue.isEmpty ? newValuePlaceholder : newFieldValue
                    resources.append(
                        ComponentResources(
                            folderName: folderName,
                            type: .process,
                            targets: []
                        )
                    )
                    newFieldValue = ""
                }) {
                    Text("Add")
                }
                TextField(newValuePlaceholder,
                          text: $newFieldValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}
