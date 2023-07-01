//import AppKit
//import Foundation
//
//struct AshFileURLGetter: LocalFileURLGetter {
//    let fileURL: URL?
//
//    func getUrl() -> URL? {
//        let openPanel = NSOpenPanel()
//        
//        openPanel.directoryURL = fileURL?.deletingLastPathComponent()
//        openPanel.allowsMultipleSelection = false
//        openPanel.canChooseFiles = true
//        openPanel.canChooseDirectories = true
//        openPanel.canCreateDirectories = true
//        openPanel.allowedContentTypes = [
//            .init(filenameExtension: "ash",
//                  conformingTo: .init("com.apple.package")!)
//        ].compactMap { $0 }
//        
//        openPanel.runModal()
//        
//        var url = openPanel.url
//        if url?.lastPathComponent.hasSuffix(".ash") == true {
//            url = url?.deletingLastPathComponent()
//        }
//        return url
//    }
//}
