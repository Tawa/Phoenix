import Factory
import RelativeURLProvider
import RelativeURLProviderContract

extension Container {
    static let relativeURLProvider = Factory(Container.shared) {
        RelativeURLProvider() as RelativeURLProviderProtocol
    }
}
