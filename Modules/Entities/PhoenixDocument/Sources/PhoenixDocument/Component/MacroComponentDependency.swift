import Foundation

public struct MacroComponentDependency: Codable, Hashable, Identifiable, Comparable {
    public var id: String { macroName }
    
    public let macroName: String
    public var targetTypes: Set<PackageTargetType> = []
    
    enum CodingKeys: String, CodingKey {
        case macroName
        case targetTypes
    }
    
    public init(
        macroName: String,
        targetTypes: Set<PackageTargetType>
    ) {
        self.macroName = macroName
        self.targetTypes = targetTypes
    }
    
    public static func < (lhs: MacroComponentDependency, rhs: MacroComponentDependency) -> Bool {
        lhs.macroName < rhs.macroName
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(macroName)
        hasher.combine(targetTypes)
    }
}
