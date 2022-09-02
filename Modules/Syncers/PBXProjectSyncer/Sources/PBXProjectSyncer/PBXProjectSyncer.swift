import PBXProjectSyncerContract
import Foundation
import PhoenixDocument

import XcodeProj
import PathKit

public struct PBXProjectSyncer: PBXProjectSyncerProtocol {
    public init() {
        
    }
    
    public func sync(document: PhoenixDocument, at documentURL: URL, withProjectAt xcodeProjectURL: URL) throws {
        print("Received: \(documentURL)")
        print("PBXProjURL: \(xcodeProjectURL)")
        let path = Path(xcodeProjectURL.path)
        
        let xcodeproj = try XcodeProj(path: path)
        var group = try xcodeproj.pbxproj.rootGroup()?.children
        try xcodeproj.write(path: path)
    }
}
