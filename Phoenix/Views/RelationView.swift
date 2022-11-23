import AccessibilityIdentifiers
import Component
import SwiftUI

struct RelationViewData {
    var types: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
    var selectionValues: [String]
}

struct RelationSelectorView<DataType>: View where DataType: Hashable {
    let title: String
    let dependencyName: String
    
    let value: DataType?
    let allValues: [DataType]
    let onValueChange: (DataType?) -> Void
    
    var body: some View {
        if allValues.count == 1 {
            Toggle(title,
                   isOn: .init(get: { value != nil },
                               set: { onValueChange($0 ? allValues[0] : nil) }))
        } else {
            HStack {
                Text(title)
                Image(systemName: "arrow.right")
                Menu(content: {
                    ForEach(allValues, id: \.self) { type in
                        Button(String(describing: type), action: { onValueChange(type) })
                            .with(accessibilityIdentifier: DependencyViewIdentifiers.option(dependencyName: dependencyName,
                                                                                            packageName: title,
                                                                                            option: String(describing: type)))
                    }
                    if value != nil {
                        Divider()
                        Button(action: { onValueChange(nil) }, label: { Text("Remove") })
                            .with(accessibilityIdentifier: DependencyViewIdentifiers.removeOption(
                                dependencyName: dependencyName,
                                packageName: title))
                    }
                }, label: {
                    Text(value.map { String(describing:$0) } ?? "Add")
                })
                .with(accessibilityIdentifier: DependencyViewIdentifiers.menu(
                    dependencyName: dependencyName,
                    packageName: title))
                .frame(width: 150)
            }
        }
    }
}

struct RelationView: View {
    @Binding var defaultDependencies: [PackageTargetType: String]
    let title: String
    let allTypes: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
    let allSelectionValues: [String]
    let onRemove: (() -> Void)?
    let onDuplicate: (() -> Void)?
    
    init(defaultDependencies: Binding<[PackageTargetType: String]>,
         title: String,
         getRelationViewDataUseCase: GetRelationViewDataUseCaseProtocol,
         onDuplicate: (() -> Void)? = nil,
         onRemove: (() -> Void)? = nil
    ) {
        _defaultDependencies = defaultDependencies
        self.title = title
        
        let viewData = getRelationViewDataUseCase.viewData(defaultDependencies: defaultDependencies.wrappedValue)
        self.allTypes = viewData.types
        self.allSelectionValues = viewData.selectionValues
        
        self.onDuplicate = onDuplicate
        self.onRemove = onRemove
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text(title)
                    .bold()
                onDuplicate.map { Button(action: $0) { Image(systemName: "doc.on.doc") } }
                onRemove.map { Button(action: $0) { Image(systemName: "trash") } }
                Spacer()
            }
            .padding(.bottom)
            LazyVStack {
                ForEach(allTypes) { dependencyType in
                    HStack {
                        RelationSelectorView<String>(
                            title: dependencyType.title,
                            dependencyName: title,
                            value: dependencyType.selectedValue,
                            allValues: allSelectionValues,
                            onValueChange: { defaultDependencies[dependencyType.value] = $0 })
                        if let subtitle = dependencyType.subtitle,
                           let subvalue = dependencyType.subValue {
                            Divider()
                            RelationSelectorView<String>(
                                title: subtitle,
                                dependencyName: title,
                                value: dependencyType.selectedSubValue,
                                allValues: allSelectionValues,
                                onValueChange: { defaultDependencies[subvalue] = $0 })
                        }
                        Spacer()
                    }
                }
            }
        }.padding()
    }
}
    
    struct RelationView_Previews: PreviewProvider {
        struct GetRelationViewDataUseCaseMock: GetRelationViewDataUseCaseProtocol {
            let relationViewData: RelationViewData
            func viewData(defaultDependencies: [PackageTargetType : String]) -> RelationViewData {
                relationViewData
            }
        }
        
        static var previews: some View {
            RelationView(
                defaultDependencies: .constant([:]),
                title: "Title",
                getRelationViewDataUseCase: GetRelationViewDataUseCaseMock(
                    relationViewData: .init(
                        types: [
                            .init(title: "Contract",
                                  subtitle: nil,
                                  value: .init(name: "Contract", isTests: false),
                                  subValue: nil,
                                  selectedValue: nil,
                                  selectedSubValue: nil),
                            .init(title: "Implementation",
                                  subtitle: "Test",
                                  value: .init(name: "Implementation", isTests: false),
                                  subValue: .init(name: "Implementation", isTests: true),
                                  selectedValue: "Contract",
                                  selectedSubValue: "Mock"),
                            .init(title: "Mock",
                                  subtitle: nil,
                                  value: .init(name: "Mocks", isTests: false),
                                  subValue: nil,
                                  selectedValue: nil,
                                  selectedSubValue: nil),
                        ],
                        selectionValues: ["Contract", "Implementation", "Mock"]
                    )
                )
            )
            .previewLayout(.fixed(width: 1000, height: 200))
        }
    }
