public enum MacOSVersion: String, Codable, Hashable, CaseIterable, Identifiable {
    public var id: Int { hashValue }

    case v12
}
