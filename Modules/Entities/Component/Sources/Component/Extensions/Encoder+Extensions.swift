import Foundation

struct AnyEncodable<FirstType: Encodable, SecondType: Encodable>: Encodable {
    let value: Any
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let encodableValue = value as? FirstType {
            try container.encode(encodableValue)
        } else if let encodableValue = value as? SecondType {
            try container.encode(encodableValue)
        }
    }
}

extension KeyedEncodingContainer {
    mutating func encodeSorted<DictionaryKey, Value>(dictionary: [DictionaryKey: Value], forKey key: Key) throws
    where DictionaryKey: Encodable,
          DictionaryKey: Comparable,
          Value: Encodable {
              let array = dictionary.keys.sorted().reduce(into: [AnyEncodable<DictionaryKey, Value>]()) { partialResult, dictionaryKey in
                  guard let value = dictionary[dictionaryKey] else { return }
                  partialResult.append(AnyEncodable(value: dictionaryKey))
                  partialResult.append(AnyEncodable(value: value))
              }
              try encode(array, forKey: key)
          }
}
