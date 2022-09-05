public enum IOSVersion: String, Codable, Hashable, CaseIterable, Identifiable {
    public var id: Int { hashValue }

    case v9
    case v10
    case v11
    case v12
    case v13
    case v14
    case v15
}
