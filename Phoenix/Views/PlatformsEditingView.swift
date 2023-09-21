import SwiftUI
import PhoenixDocument
import Foundation
import SwiftPackage

struct PlatformsEditingView: View {
    @Binding var component: Component

    var body: some View {
        Text("Platforms:")
        CustomMenu(title: iOSPlatformMenuTitle(iOSVersion: component.iOSVersion),
                   data: IOSVersion.allCases,
                   onSelection: { component.iOSVersion = $0 },
                   hasRemove: component.iOSVersion != nil,
                   onRemove: { component.iOSVersion = nil })
        .frame(width: 150)
        CustomMenu(title: macCatalystPlatformMenuTitle(macCatalystVersion: component.macCatalystVersion),
                   data: MacCatalystVersion.allCases,
                   onSelection: { component.macCatalystVersion = $0 },
                   hasRemove: component.macCatalystVersion != nil,
                   onRemove: { component.macCatalystVersion = nil })
        .frame(width: 150)
        CustomMenu(title: macOSPlatformMenuTitle(macOSVersion: component.macOSVersion),
                   data: MacOSVersion.allCases,
                   onSelection: { component.macOSVersion = $0 },
                   hasRemove: component.macOSVersion != nil,
                   onRemove: { component.macOSVersion = nil })
        .frame(width: 150)
        CustomMenu(title: tvOSPlatformMenuTitle(tvOSVersion: component.tvOSVersion),
                   data: TVOSVersion.allCases,
                   onSelection: { component.tvOSVersion = $0 },
                   hasRemove: component.tvOSVersion != nil,
                   onRemove: { component.tvOSVersion = nil })
        .frame(width: 150)
        CustomMenu(title: watchOSPlatformMenuTitle(watchOSVersion: component.watchOSVersion),
                   data: WatchOSVersion.allCases,
                   onSelection: { component.watchOSVersion = $0 },
                   hasRemove: component.watchOSVersion != nil,
                   onRemove: { component.watchOSVersion = nil })
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
