import Foundation

public struct MacroComponent: Codable, Hashable, Identifiable {
    public let id: String = UUID().uuidString
    public var name: String
    
    enum CodingKeys: CodingKey {
        case name
    }
    
    public init(name: String) {
        self.name = name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
