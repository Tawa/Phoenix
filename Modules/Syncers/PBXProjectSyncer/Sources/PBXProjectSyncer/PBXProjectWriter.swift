import Foundation
import PathKit
import XcodeProj

class PackageDescription {
    var name: String
    var path: String

    internal init(name: String, path: String) {
        self.name = name
        self.path = path
    }
}

public class Group {
    var name: String
    var children: [Group]
    var packages: [PackageDescription]

    internal init(name: String, children: [Group], packages: [PackageDescription]) {
        self.name = name
        self.children = children
        self.packages = packages
    }
}

public protocol PBXProjectWriterProtocol {
    func write(group: Group, xcodeProjectURL: URL) throws
}

public struct PBXProjectWriter: PBXProjectWriterProtocol {
    public init() {
        
    }
    
    public func write(group: Group, xcodeProjectURL: URL) throws {
        let sourceRoot = Path(xcodeProjectURL.path)
        
        let xcodeproj = try XcodeProj(path: sourceRoot)
        let pbxproj = xcodeproj.pbxproj
        if let rootGroup = try pbxproj.rootGroup() {
            try add(group: group, toGroup: rootGroup, sourceRoot: sourceRoot)
        }
        try xcodeproj.write(path: sourceRoot)
    }
    
    func add(group: Group, toGroup: PBXGroup, sourceRoot: Path) throws {
        let newGroup = try getGroup(named: group.name, fromGroup: toGroup)
        
        for child in group.children {
            try add(group: child,
                    toGroup: newGroup,
                    sourceRoot: sourceRoot)
        }
        
        for package in group.packages {
            let fileReference = try newGroup.addFile(at: Path(package.path),
                                                     sourceRoot: Path(),
                                                     validatePresence: false)
            fileReference.lastKnownFileType = "wrapper"
        }
    }
    
    func getGroup(named name: String, fromGroup group: PBXGroup) throws -> PBXGroup {
        return try group.group(named: name) ?? group.addGroup(named: name).first!
    }
}
