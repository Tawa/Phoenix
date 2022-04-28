import Foundation
public struct TargetResources: Codable, Hashable {
    public enum ResourcesType: String, Codable, Hashable, Identifiable, CaseIterable{
        public var id: Int { hashValue }
        case process
        case copy
    }

    public let id: String
    public let folderName: String
    public let resourcesType: ResourcesType

    public init(id: String, folderName: String, resourcesType: TargetResources.ResourcesType) {
        self.id = id
        self.folderName = folderName
        self.resourcesType = resourcesType
    }
}
