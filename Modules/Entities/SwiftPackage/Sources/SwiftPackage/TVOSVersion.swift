public enum TVOSVersion: String, Codable, Hashable, CaseIterable, Identifiable {
    public var id: Int { hashValue }
    
    case v11
    case v12
    case v13
    case v14
    case v15
    case v16
}
