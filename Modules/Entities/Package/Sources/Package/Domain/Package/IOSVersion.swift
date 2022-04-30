public enum IOSVersion: String, Codable, Hashable, CaseIterable, Identifiable {
    public var id: Int { hashValue }

    case v13
    case v14
    case v15
}
