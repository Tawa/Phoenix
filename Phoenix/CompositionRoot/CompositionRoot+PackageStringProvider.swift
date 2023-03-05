import Factory
import PackageStringProvider
import PackageStringProviderContract

extension Container {
    static let packageStringProvider = Factory(Container.shared) {
        PackageStringProvider() as PackageStringProviderProtocol
    }
}
