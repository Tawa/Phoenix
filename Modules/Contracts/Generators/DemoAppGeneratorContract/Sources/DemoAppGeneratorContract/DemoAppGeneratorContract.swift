import Foundation
import Package

public protocol DemoAppGeneratorProtocol {
    func generateDemoApp(forComponent component: Component,
                         of family: Family,
                         at url: URL,
                         relativeURL: URL) throws
}
