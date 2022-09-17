import Foundation
import SwiftPackage

public protocol DemoAppGeneratorProtocol {
    func generateDemoApp(forComponent component: Component,
                         of family: Family,
                         families: [ComponentsFamily],
                         projectConfiguration: ProjectConfiguration,
                         at url: URL,
                         relativeURL: URL) throws
}
