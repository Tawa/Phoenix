import AppKit
import Foundation

struct XcodeProjURLGetter: LocalFileURLGetter {
    let fileURL: URL?
    
    func getUrl() -> URL? {
        let openPanel = NSOpenPanel()
        
        openPanel.directoryURL = fileURL?.deletingLastPathComponent()
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
