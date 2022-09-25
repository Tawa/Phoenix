import Foundation

public protocol DemoAppOutputProtocol {
    var folderURL: URL { get }
    var xcodeProjURL: URL { get }
}

public protocol DemoAppGeneratorProtocol {
    func generateDemoApp(named name: String,
                         at url: URL) throws -> DemoAppOutputProtocol
}
