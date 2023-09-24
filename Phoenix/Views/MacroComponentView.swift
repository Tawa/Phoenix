import PhoenixDocument
import SwiftPackage
import SwiftUI

struct MacroComponentView: View {
    @Binding var macroComponent: MacroComponent
    let relationViewData: RelationViewData
    let onRemove: () -> Void
    
    var body: some View {
        List {
            headerView()
            platformsContent()
            defaultDependenciesView()
        }
    }
    
    @ViewBuilder private func headerView() -> some View {
        SectionView {
            Text(macroComponent.name)
                .font(.largeTitle.bold())
            Spacer()
            Button(role: .destructive, action: onRemove) {
                Image(systemName: "trash")
            }.help("Remove")
        }
    }
    
    @ViewBuilder private func platformsContent() -> some View {
        SectionView {
            Text("Platforms:")
            PlatformsEditingView(platforms: $macroComponent.platforms)
        }
    }
    
    @ViewBuilder private func defaultDependenciesView() -> some View {
        SectionView {
            RelationView(
                defaultDependencies: $macroComponent.defaultDependencies.toStringDictionaryBinding(),
                title: "Default Dependencies",
                viewData: relationViewData
            )
        }
    }
}
