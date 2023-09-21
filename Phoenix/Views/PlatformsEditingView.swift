import SwiftUI
import PhoenixDocument
import Foundation
import SwiftPackage

struct PlatformsEditingView: View {
    @Binding var platforms: Component.Platforms

    var body: some View {
        Text("Platforms:")
        CustomMenu(title: iOSPlatformMenuTitle(iOSVersion: platforms.iOSVersion),
                   data: IOSVersion.allCases,
                   onSelection: { platforms.iOSVersion = $0 },
                   hasRemove: platforms.iOSVersion != nil,
                   onRemove: { platforms.iOSVersion = nil })
        .frame(width: 150)
        CustomMenu(title: macCatalystPlatformMenuTitle(macCatalystVersion: platforms.macCatalystVersion),
                   data: MacCatalystVersion.allCases,
                   onSelection: { platforms.macCatalystVersion = $0 },
                   hasRemove: platforms.macCatalystVersion != nil,
                   onRemove: { platforms.macCatalystVersion = nil })
        .frame(width: 150)
        CustomMenu(title: macOSPlatformMenuTitle(macOSVersion: platforms.macOSVersion),
                   data: MacOSVersion.allCases,
                   onSelection: { platforms.macOSVersion = $0 },
                   hasRemove: platforms.macOSVersion != nil,
                   onRemove: { platforms.macOSVersion = nil })
        .frame(width: 150)
        CustomMenu(title: tvOSPlatformMenuTitle(tvOSVersion: platforms.tvOSVersion),
                   data: TVOSVersion.allCases,
                   onSelection: { platforms.tvOSVersion = $0 },
                   hasRemove: platforms.tvOSVersion != nil,
                   onRemove: { platforms.tvOSVersion = nil })
        .frame(width: 150)
        CustomMenu(title: watchOSPlatformMenuTitle(watchOSVersion: platforms.watchOSVersion),
                   data: WatchOSVersion.allCases,
                   onSelection: { platforms.watchOSVersion = $0 },
                   hasRemove: platforms.watchOSVersion != nil,
                   onRemove: { platforms.watchOSVersion = nil })
        .frame(width: 150)
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
