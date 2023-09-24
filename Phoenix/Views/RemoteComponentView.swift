import PhoenixDocument
import SwiftPackage
import SwiftUI

struct RemoteComponentView: View {
    @Binding var remoteComponent: RemoteComponent
    let onRemove: () -> Void
    
    @State private var showingNamePopup: Bool = false
    
    var body: some View {
        List {
            headerView()
            versionView()
            namesView()
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
        SectionView {
            Text(remoteComponent.url)
                .font(.largeTitle.bold())
            Spacer()
            Button(role: .destructive, action: onRemove) {
                Image(systemName: "trash")
            }.help("Remove")
        }
    }
    
    @ViewBuilder private func versionView() -> some View {
        SectionView {
            Text("Version:")
            ExternalDependencyVersionView(version: $remoteComponent.version)
        }
    }
    
    @ViewBuilder private func namesView() -> some View {
        SectionView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Names/Packages:")
                        .bold()
                    Button(action: onAddName) {
                        Image(systemName: "plus")
                    }
                }
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
            }
        }
    }
    
    // MARK: - Helper Functions
    private func onAddName() {
        showingNamePopup = true
    }
    
    private func remove(name: ExternalDependencyName) {
        remoteComponent.names.removeAll(where: { $0 == name })
    }
}
