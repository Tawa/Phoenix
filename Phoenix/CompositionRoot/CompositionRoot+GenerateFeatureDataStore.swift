import Factory
import Foundation
import GenerateFeatureDataStore
import GenerateFeatureDataStoreContract

extension Container {
    static let generateFeatureDataStore = Factory(Container.shared) {
        GenerateFeatureDataStore(
            dictionaryCache: UserDefaults.standard
        ) as GenerateFeatureDataStoreProtocol
    }.scope(.singleton)
}
