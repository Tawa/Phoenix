import Foundation
public struct TargetResources: Codable, Hashable {
    public enum ResourcesType: String, Codable, Hashable, Identifiable, CaseIterable{
        public var id: Int { hashValue }
        case process
        case copy
    }

    public let folderName: String
    public let resourcesType: ResourcesType

    public init(folderName: String, resourcesType: TargetResources.ResourcesType) {
        self.folderName = folderName
        self.resourcesType = resourcesType
    }
}
