import AccessibilityIdentifiers
import Combine
import Factory
import PhoenixDocument
import SwiftUI
import SwiftPackage

struct MetaComponentView: View {
    @Binding var component: Component
    let remoteDependencies: [String: RemoteComponent]
    let relationViewData: RelationViewData
    let relationViewDataToComponentNamed: (Name, [PackageTargetType: String]) -> RelationViewData
    let relationViewDataToMacroComponentNamed: (String, Set<PackageTargetType>) -> RelationViewData
    let titleForComponentNamed: (Name) -> String
    
    let onGenerateDemoAppProject: () -> Void
    let onRemove: () -> Void
    let allTargetTypes: [IdentifiableWithSubtype<PackageTargetType>]
    let onShowDependencySheet: () -> Void
    let onShowRemoteDependencySheet: () -> Void
    let onShowMacroDependencySheet: () -> Void
    let onSelectComponentName: (Name) -> Void
    let onSelectRemoteURL: (String) -> Void
    let onSelectMacroName: (String) -> Void
    let allModuleTypes: [String]
    
    // MARK: - Private
    private var title: String { titleForComponentNamed(component.name) }
    
    @State private var showingLocalDependencies: Bool = false
    @State private var showingRemoteDependencies: Bool = false
    @State private var showingMacroDependencies: Bool = false
    @State private var showingResources: Bool = false

    var body: some View {
        List {
            headerView()
            platformsContent()
            localDependenciesView()
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder private func headerView() -> some View {
        SectionView {
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.leading)
            Spacer()
            Button(action: onGenerateDemoAppProject) {
                Text("Generate Demo App")
            }.help("Generate Demo App Xcode Project")
            Button(role: .destructive, action: onRemove) {
                Image(systemName: "trash")
            }.help("Remove")
        }
    }
    
    @ViewBuilder private func platformsContent() -> some View {
        SectionView {
            Text("Platforms:")
            PlatformsEditingView(platforms: $component.platforms)
        }
    }
    
    @ViewBuilder private func localDependenciesView() -> some View {
        expandableDependenciesSection(
            title: "Components",
            isExpanded: $showingLocalDependencies,
            accessibilityIdentifier: ComponentIdentifiers.localDependenciesButton) {
                LazyVStack {
                    ForEach($component.localDependencies) { localDependency in
                        HStack {
                            Divider()
                            componentDependencyView(for: localDependency)
                        }
                    }
                }
                if component.localDependencies.isEmpty {
                    Text("No Components")
                }
            } accessoryContent: {
                Button(action: onShowDependencySheet) { Image(systemName: "plus") }
                    .with(accessibilityIdentifier: ComponentIdentifiers.dependenciesPlusButton)
            }
    }
    
    @ViewBuilder private func componentDependencyView(for dependency: Binding<ComponentDependency>) -> some View {
        RelationView(
            defaultDependencies: dependency.targetTypes,
            title: titleForComponentNamed(dependency.wrappedValue.name),
            viewData: relationViewDataToComponentNamed(dependency.wrappedValue.name, dependency.wrappedValue.targetTypes),
            onSelect: { onSelectComponentName(dependency.wrappedValue.name) },
            onRemove: { component.localDependencies.removeAll(where: { $0.name == dependency.wrappedValue.name }) }
        )
    }
    
    // MARK: - Helper Functions
    @ViewBuilder private func expandableSection<Title: View, Content: View, AccessoryContent: View>(
        isExpanded: Binding<Bool>,
        accessibilityIdentifier: AccessibilityIdentifiable,
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder accessoryContent: @escaping () -> AccessoryContent = { EmptyView() }
    ) -> some View {
        Section {
            if isExpanded.wrappedValue {
                content()
            } else {
                EmptyView()
            }
        } header: {
            HStack {
                Button {
                    isExpanded.wrappedValue.toggle()
                } label: {
                    title()
                }
                .buttonStyle(PlainButtonStyle())
                .with(accessibilityIdentifier: accessibilityIdentifier)
                accessoryContent()
            }
        }
    }
    
    @ViewBuilder private func expandableDependenciesSection<Content: View, AccessoryContent: View>(
        title: String,
        isExpanded: Binding<Bool>,
        accessibilityIdentifier: AccessibilityIdentifiable,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder accessoryContent: @escaping () -> AccessoryContent = { EmptyView() }
    ) -> some View {
        expandableSection(
            isExpanded: isExpanded,
            accessibilityIdentifier: accessibilityIdentifier,
            title: {
                HStack {
                    Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.forward")
                    Text(title)
                }
                .font(.largeTitle.bold())
            },
            content: content,
            accessoryContent: accessoryContent
        )
    }

    private func isModuleTypeOn(_ name: String) -> Bool {
        component.modules[name] != nil
    }
}
