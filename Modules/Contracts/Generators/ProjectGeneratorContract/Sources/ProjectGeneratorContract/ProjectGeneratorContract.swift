import PhoenixDocument
import Foundation

public protocol ProjectGeneratorProtocol {
    func generate(document: PhoenixDocument, folderURL: URL) throws
}
