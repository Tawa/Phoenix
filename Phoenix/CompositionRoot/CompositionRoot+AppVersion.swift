import AppVersionProvider
import AppVersionProviderContract
import Factory
import Foundation
import SwiftUI

extension Container {
    static let currentAppVersionStringProvider = Factory(Container.shared) {
        Bundle.main as CurrentAppVersionStringProviderProtocol
    }
    
    static let appVersionStringParser = Factory(Container.shared) {
        AppVersionStringParser() as AppVersionStringParserProtocol
    }
    
    static let currentAppVersionProvider = Factory(Container.shared) {
        CurrentAppVersionProvider(
            appVersionStringProvider: Container.currentAppVersionStringProvider(),
            appVersionStringParser: Container.appVersionStringParser()
        ) as CurrentAppVersionProviderProtocol
    }
    
    static let appVersionUpdateProvider = Factory(Container.shared) {
        AppVersionUpdateFilteredProvider(
            appVersionUpdateProvider: Container.remoteAppVersionUpdateProvider(),
            appVersionStringParser: Container.appVersionStringParser(),
            currentAppVersionProvider: Container.currentAppVersionProvider()
        ) as AppVersionUpdateProviderProtocol
    }
    
    private static let remoteAppVersionUpdateProvider = Factory<AppVersionUpdateProviderProtocol>(Container.shared) {
        if Container.isGitHubRelease {
            return GitHubVersionUpdateProvider()
        } else {
            return AppStoreVersionUpdateProvider()
        }
    }
    
    static let updateButton = Factory<AnyView>(Container.shared) {
        if Container.isGitHubRelease {
            return AnyView(gitHubUpdateButton())
        } else {
            return AnyView(appStoreUpdateButton())
        }
    }
    
    private static let gitHubUpdateButton = Factory(Container.shared) {
        GitHubUpdateView()
    }
    
    private static let appStoreUpdateButton = Factory(Container.shared) {
        Link(destination: URL(string: "https://apps.apple.com/us/app/phoenix-app/id1626793172")!) {
            Text("Update")
        }
    }
}

extension Bundle: CurrentAppVersionStringProviderProtocol {
    public func currentAppVersionString() -> String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

struct GitHubUpdateView: View {
    @State var isShowingUpdate: Bool = false
    
    var body: some View {
        Button("Githupdate", action: {
            isShowingUpdate = true
        })
        .sheet(isPresented: $isShowingUpdate) {
            VStack {
                Text("Downloading Update")
                ProgressView()
                    .padding()
                Button("Cancel") {
                    isShowingUpdate = false
                }
            }
            .padding()
        }
    }
}
