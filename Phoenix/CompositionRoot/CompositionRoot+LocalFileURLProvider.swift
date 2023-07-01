import Factory
import Foundation
import LocalFileURLProvider
import LocalFileURLProviderContract

extension Container {
    static let ashFileURLProvider = ParameterFactory(Container.shared) { (fileURL: URL?) in
        AshFileURLProvider(initialURL: fileURL) as LocalFileURLProviderProtocol
    }
    
    static let xcodeProjURLProvider = ParameterFactory(Container.shared) { (fileURL: URL?) in
        XcodeProjURLProvider(initialURL: fileURL) as LocalFileURLProviderProtocol
    }
}
