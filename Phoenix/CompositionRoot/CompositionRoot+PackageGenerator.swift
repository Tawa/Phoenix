import Factory
import PackageGenerator
import PackageGeneratorContract

extension Container {
    static let packageGenerator = Factory(Container.shared) {
        PackageGenerator(
            fileManager: .default,
            packageStringProvider: packageStringProvider()
        ) as PackageGeneratorProtocol
    }
}
