public struct TargetResources: Codable, Hashable {
    public enum ResourcesType: Codable, Hashable {
        case process
        case copy
    }

    public let folderName: String
    public let resourcesType: ResourcesType
}
