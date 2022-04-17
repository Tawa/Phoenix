import Package

struct ComponentsFamily: Codable, Hashable, Identifiable {
    var id: String { family.name }
    var family: Family
    var components: [Component]
}
