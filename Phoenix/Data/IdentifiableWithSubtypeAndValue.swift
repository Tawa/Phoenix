import Foundation

struct IdentifiableWithSubtypeAndSelection<ValueType, SelectionType>: Identifiable
where ValueType: Identifiable, SelectionType: Identifiable {
    var id: ValueType.ID { value.id }
    let title: String
    let subtitle: String?
    let value: ValueType
    let subValue: ValueType?
    let selectedValue: SelectionType?
    let selectedSubValue: SelectionType?
}
