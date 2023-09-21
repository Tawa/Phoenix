public enum MacCatalystVersion: String, Codable, Hashable, CaseIterable, Identifiable {
    public var id: Int { hashValue }
    
    case v13
    case v14
    case v15
    case v16
    case v17
}
