import Foundation
import Package

public protocol DemoAppGeneratorProtocol {
    func generateDemoApp(forComponent component: Component,
                         of family: Family,
                         families: [ComponentsFamily],
                         projectConfiguration: ProjectConfiguration,
                         at url: URL,
                         relativeURL: URL) throws
}
