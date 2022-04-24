public enum IOSVersion: Codable, Hashable, CaseIterable, Identifiable {
    public var id: Int { hashValue }

    case v13
    case v14
    case v15
}
