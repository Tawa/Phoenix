import PhoenixDocument
import SwiftPackage
import SwiftUI

struct TargetTypesView: View {
    @Binding var targetTypes: [PackageTargetType]
    let allDependencyTypes: [IdentifiableWithSubtype<PackageTargetType>]

    var body: some View {
        VStack {
            ForEach(allDependencyTypes) { dependencyType in
                HStack {
                    Toggle(isOn: .init(get: { targetTypes.contains(where: { dependencyType.value == $0 }) },
                                       set: {
                        if $0 {
                            targetTypes.append(dependencyType.value)
                        } else {
                            targetTypes.removeAll(where: { $0 == dependencyType.value })
                        }
                    })) {
                        Text(dependencyType.title)
                    }
                    if let subtitle = dependencyType.subtitle, let subvalue = dependencyType.subValue {
                        Toggle(isOn: .init(get: { targetTypes.contains(where: { subvalue == $0 }) },
                                           set: {
                            if $0 {
                                targetTypes.append(subvalue)
                            } else {
                                targetTypes.removeAll(where: { $0 == subvalue })
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
}
