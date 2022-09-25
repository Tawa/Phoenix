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
    var path: String
    var children: [Group]
    var packages: [PackageDescription]

    internal init(name: String, path: String, children: [Group], packages: [PackageDescription]) {
        self.name = name
        self.path = path
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
            try add(group: group, toGroup: rootGroup)
        }
        try pbxproj.write(
            path: Path(xcodeProjectURL.appendingPathComponent("project.pbxproj").path),
            override: true
        )
    }
    
    func add(group: Group, toGroup: PBXGroup) throws {
        guard let newGroup = try getGroup(named: group.name,
                                          path: group.path,
                                          fromGroup: toGroup)
        else { return }
        
        for child in group.children {
            try add(group: child,
                    toGroup: newGroup)
        }
        
        for package in group.packages {
            try newGroup.addFile(at: Path(package.path),
                                 sourceRoot: Path(),
                                 validatePresence: false)
        }
    }
    
    func getGroup(named name: String, path: String, fromGroup group: PBXGroup) throws -> PBXGroup? {
        let children: [PBXGroup] = group.children.compactMap { $0 as? PBXGroup }
        let newGroup = try children.first(where: { $0.path == name }) ?? group.addGroup(named: name).first
        
        if !path.isEmpty, name != path {
            newGroup?.path = path
        }
        if newGroup?.path == newGroup?.name {
            newGroup?.name = nil
        }
        
        return newGroup
    }
}
