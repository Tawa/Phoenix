import Foundation

struct IdentifiableWithSubtype<ValueType>: Identifiable where ValueType: Identifiable {
    var id: ValueType.ID { value.id }
    let title: String
    let subtitle: String?
    let value: ValueType
    let subValue: ValueType?
}
