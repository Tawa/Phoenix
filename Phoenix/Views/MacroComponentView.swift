import PhoenixDocument
import SwiftPackage
import SwiftUI

struct MacroComponentView: View {
    @Binding var macroComponent: MacroComponent
    let onRemove: () -> Void
    
    var body: some View {
        List {
            headerView()
            platformsContent()
        }
    }
    
    @ViewBuilder private func headerView() -> some View {
        section {
            Text(macroComponent.name)
                .font(.largeTitle.bold())
            Spacer()
            Button(role: .destructive, action: onRemove) {
                Image(systemName: "trash")
            }.help("Remove")
        }
    }
    
    @ViewBuilder private func platformsContent() -> some View {
        section {
            Text("Platforms:")
            CustomMenu(title: iOSPlatformMenuTitle(iOSVersion: macroComponent.iOSVersion),
                       data: IOSVersion.allCases,
                       onSelection: { macroComponent.iOSVersion = $0 },
                       hasRemove: macroComponent.iOSVersion != nil,
                       onRemove: { macroComponent.iOSVersion = nil })
            .frame(width: 150)
            CustomMenu(title: macCatalystPlatformMenuTitle(macCatalystVersion: macroComponent.macCatalystVersion),
                       data: MacCatalystVersion.allCases,
                       onSelection: { macroComponent.macCatalystVersion = $0 },
                       hasRemove: macroComponent.macCatalystVersion != nil,
                       onRemove: { macroComponent.macCatalystVersion = nil })
            .frame(width: 150)
            CustomMenu(title: macOSPlatformMenuTitle(macOSVersion: macroComponent.macOSVersion),
                       data: MacOSVersion.allCases,
                       onSelection: { macroComponent.macOSVersion = $0 },
                       hasRemove: macroComponent.macOSVersion != nil,
                       onRemove: { macroComponent.macOSVersion = nil })
            .frame(width: 150)
            CustomMenu(title: tvOSPlatformMenuTitle(tvOSVersion: macroComponent.tvOSVersion),
                       data: TVOSVersion.allCases,
                       onSelection: { macroComponent.tvOSVersion = $0 },
                       hasRemove: macroComponent.tvOSVersion != nil,
                       onRemove: { macroComponent.tvOSVersion = nil })
            .frame(width: 150)
            CustomMenu(title: watchOSPlatformMenuTitle(watchOSVersion: macroComponent.watchOSVersion),
                       data: WatchOSVersion.allCases,
                       onSelection: { macroComponent.watchOSVersion = $0 },
                       hasRemove: macroComponent.watchOSVersion != nil,
                       onRemove: { macroComponent.watchOSVersion = nil })
            .frame(width: 150)
        }
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
    
    private func iOSPlatformMenuTitle(iOSVersion: IOSVersion?) -> String {
        iOSVersion.map { ".iOS(.\($0))"  } ?? "Add iOS"
    }

    private func macCatalystPlatformMenuTitle(macCatalystVersion: MacCatalystVersion?) -> String {
        macCatalystVersion.map { ".macCatalyst(.\($0))"  } ?? "Add macCatalyst"
    }

    private func macOSPlatformMenuTitle(macOSVersion: MacOSVersion?) -> String {
        macOSVersion.map { ".macOS(.\($0))"  } ?? "Add macOS"
    }

    private func tvOSPlatformMenuTitle(tvOSVersion: TVOSVersion?) -> String {
        tvOSVersion.map { ".tvOS(.\($0))"  } ?? "Add tvOS"
    }

    private func watchOSPlatformMenuTitle(watchOSVersion: WatchOSVersion?) -> String {
        watchOSVersion.map { ".watchOS(.\($0))"  } ?? "Add watchOS"
    }
}
