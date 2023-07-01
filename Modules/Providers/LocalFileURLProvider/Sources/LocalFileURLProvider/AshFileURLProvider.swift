import AppKit
import Foundation
import LocalFileURLProviderContract
import UniformTypeIdentifiers

public struct AshFileURLProvider: LocalFileURLProviderProtocol {
    let initialURL: URL?
    
    public init(initialURL: URL?) {
        self.initialURL = initialURL
    }
    
    public func localFileURL() -> URL? {
        let openPanel = NSOpenPanel()
        
        openPanel.directoryURL = initialURL?.deletingLastPathComponent()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.allowedContentTypes = [
            .init(filenameExtension: "ash",
                  conformingTo: .init("com.apple.package")!)
        ].compactMap { $0 }
        
        openPanel.runModal()
        
        var url = openPanel.url
        if url?.lastPathComponent.hasSuffix(".ash") == true {
            url = url?.deletingLastPathComponent()
        }
        return url
    }
}
