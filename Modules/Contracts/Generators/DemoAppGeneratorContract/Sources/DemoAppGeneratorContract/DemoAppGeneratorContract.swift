import Foundation

public protocol DemoAppGeneratorProtocol {
    func generateDemoApp(named name: String,
                         at url: URL) throws
}
