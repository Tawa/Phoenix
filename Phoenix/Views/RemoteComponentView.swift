import Component
import SwiftPackage
import SwiftUI

struct RemoteComponentView: View {
    @Binding var remoteComponent: RemoteComponent
    let onRemove: () -> Void
    
    @State private var showingNamePopup: Bool = false
    @State private var showingMentions: Bool = false
    let mentions: [Name]
    let titleForComponentNamed: (Name) -> String
    let onSelectComponentName: (Name) -> Void

    var body: some View {
        List {
            headerView()
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading) {
                    versionView()
                    namesView()
                }
                mentionsView()
            }
        }
        .sheet(isPresented: $showingNamePopup) {
            NewRemoteComponentNameSheet { name in
                guard !remoteComponent.names.contains(where: { $0 == name })
                else {
                    throw NSError(domain: "Name \(name) already added.", code: 504)
                }
                remoteComponent.names.append(name)
                remoteComponent.names.sort(by: { $0.name < $1.name })
                showingNamePopup = false
            } onDismiss: {
                showingNamePopup = false
            }
        }
    }
    
    @ViewBuilder private func headerView() -> some View {
        section {
            Text(remoteComponent.url)
                .font(.largeTitle.bold())
            Spacer()
            Button(role: .destructive, action: onRemove) {
                Image(systemName: "trash")
            }.help("Remove")
        }
    }
    
    @ViewBuilder private func versionView() -> some View {
        section {
            Text("Version:")
            ExternalDependencyVersionView(version: $remoteComponent.version)
        }
    }
    
    @ViewBuilder private func namesView() -> some View {
        section {
            VStack(alignment: .leading) {
                Text("Names/Packages:")
                if remoteComponent.names.isEmpty {
                    Text("No Names/Packages added yet.")
                        .italic()
                        .foregroundColor(.gray)
                }
                ForEach($remoteComponent.names) { name in
                    HStack {
                        Divider()
                        ExternalDependencyNameView(name: name) {
                            remove(name: name.wrappedValue)
                        }
                    }
                }
                Button(action: onAddName) {
                    Text("Add")
                }
            }
        }
    }
    
    @ViewBuilder private func mentionsView() -> some View {
        MentionsView(
            showing: $showingMentions,
            mentions: mentions,
            title: remoteComponent.url,
            titleForComponentNamed: titleForComponentNamed,
            onSelectComponentName: onSelectComponentName,
            alignment: .leading
        )
    }
    
    // MARK: - Helper Functions
    @ViewBuilder private func section<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        Section {
            HStack(alignment: .center) {
                content()
            }
            Divider()
        }
    }

    private func onAddName() {
        showingNamePopup = true
    }
    
    private func remove(name: ExternalDependencyName) {
        remoteComponent.names.removeAll(where: { $0 == name })
    }
}
