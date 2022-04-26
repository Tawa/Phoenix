public enum LibraryType: Codable, Hashable, CaseIterable, Identifiable {
    public var id: Int { hashValue }

    case dynamic
    case `static`
}
