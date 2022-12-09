import AccessibilityIdentifiers
import Factory
import Combine
import Component
import ComponentDetailsProviderContract
import SwiftUI

extension Binding where Value == String? {
    var nonOptionalBinding: Binding<String> {
        Binding<String> {
            wrappedValue ?? ""
        } set: {
            wrappedValue = $0.nilIfEmpty
        }

    }
}

extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

extension Binding where Value == Bool {
    var inversed: Binding<Bool> {
        Binding(get: { !wrappedValue },
                set: { wrappedValue = !$0 })
    }
}

struct FamilyRule: Identifiable {
    var id: String { name }
    let name: String
    let enabled: Bool
}

struct FamilySheet: View {
    @Binding var family: Family
    let relationViewData: RelationViewData
    let rules: [FamilyRule]
    let onDismiss: () -> Void
    
    // MARK: - Private
    @Injected(Container.familyFolderNameProvider) private var familyFolderNameProvider
    private var name: String { family.name }
    private var defaultFolderName: String { familyFolderNameProvider.folderName(forFamily: family.name) }
    private var componentNameExample: String { "Component\(family.ignoreSuffix ? "" : family.name)" }
    private var folderName: Binding<String> { .init(get: { family.folder ?? "" }, set: { family.folder = $0.nilIfEmpty })}
    
    init(
        family: Binding<Family>,
        relationViewData: RelationViewData,
        rules: [FamilyRule],
        onDismiss: @escaping () -> Void
    ) {
        self._family = family
        self.relationViewData = relationViewData
        self.rules = rules
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Family: \(name)")
                    .font(.largeTitle)
                
                Toggle(isOn: $family.ignoreSuffix.inversed) {
                    Text("Append Component Name with Family Name. ")
                        .bold()
                    + Text("\nExample: \(componentNameExample)")
                        .font(.subheadline.italic())
                }.with(accessibilityIdentifier: FamilySheetIdentifiers.appendNameToggle)
                
                HStack {
                    Text("Folder Name:")
                    TextField("Default: (\(defaultFolderName))",
                              text: folderName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .with(accessibilityIdentifier: FamilySheetIdentifiers.folderNameTextField)
                    Button(action: { family.folder = nil }) {
                        Text("Use Default")
                    }
                }
                
                Spacer().frame(height: 30)
                
                RelationView(defaultDependencies: $family.defaultDependencies,
                             title: "Default Dependencies",
                             viewData: relationViewData
                )
                
                VStack(alignment: .leading) {
                    Text("Allow ") + Text(name).bold() + Text(" components to be used in:")
                    ForEach(rules) { rule in
                        Toggle(rule.name,
                               isOn: Binding(get: { rule.enabled },
                                             set: { enabled in
                            if enabled {
                                family.excludedFamilies.removeAll(where: { rule.name == $0 })
                            } else {
                                family.excludedFamilies.append(rule.name)
                                family.excludedFamilies.sort()
                            }
                        })
                        )
                    }
                }
                .padding()
                
                Button(action: onDismiss) {
                    Text("Done")
                }
                .keyboardShortcut(.cancelAction)
                .with(accessibilityIdentifier: FamilySheetIdentifiers.doneButton)
                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 600, maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}
