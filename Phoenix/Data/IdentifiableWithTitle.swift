import Foundation

struct IdentifiableWithTitle<Data>: Identifiable where Data: Identifiable {
    var id: Data.ID { value.id }
    let title: String
    let value: Data
}
