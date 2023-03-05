import DemoAppGenerator
import DemoAppGeneratorContract
import Factory
import Foundation

extension Container {
    static let demoAppGenerator = Factory(Container.shared) {
        DemoAppGenerator(
            fileManager: FileManager.default
        ) as DemoAppGeneratorProtocol
    }
}
