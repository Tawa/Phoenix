public enum WatchOSVersion: String, Codable, Hashable, CaseIterable, Identifiable {
    public var id: Int { hashValue }
    
    case v4
    case v5
    case v6
    case v7
    case v8
    case v9
}
