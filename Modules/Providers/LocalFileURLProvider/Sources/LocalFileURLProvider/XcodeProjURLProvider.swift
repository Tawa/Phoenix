import AppKit
import Foundation
import LocalFileURLProviderContract

public struct XcodeProjURLProvider: LocalFileURLProviderProtocol {
    let initialURL: URL?
    
    public init(initialURL: URL?) {
        self.initialURL = initialURL
    }
    
    public func localFileURL() -> URL? {
        let openPanel = NSOpenPanel()
        
        openPanel.directoryURL = initialURL?.deletingLastPathComponent()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.allowedContentTypes = [
            .init(filenameExtension: "xcodeproj",
                  conformingTo: .init("com.apple.package")!)
        ].compactMap { $0 }
        
        openPanel.runModal()
        
        return openPanel.url
    }
}
