import PBXProjectSyncerContract
import Foundation
import PhoenixDocument

import XcodeProj
import PathKit

public struct PBXProjectSyncer: PBXProjectSyncerProtocol {
    public init() {
        
    }
    
    public func sync(document: PhoenixDocument, at documentURL: URL, withProjectAt xcodeProjectURL: URL) throws {
        let path = Path(xcodeProjectURL.path)
        
        let xcodeproj = try XcodeProj(path: path)
        let pbxproj = xcodeproj.pbxproj
        let rootGroup = try pbxproj.rootGroup()
//        if let group = rootGroup?.group(named: "PhoenixModules") {
//            print("Found Group: \(group.uuid)")
//            rootGroup?.children.removeAll(where: { element in
//                element.name == "PhoenixModules"
//            })
//        } else {
//            let newGroup = try rootGroup?.addGroup(named: "PhoenixModules", options: .withoutFolder)
//            try newGroup?.first?.addGroup(named: "Contracts", options: .withoutFolder)
//            print("New Group: \(newGroup?.count)")
//        }
        try xcodeproj.write(path: path)
    }
}
