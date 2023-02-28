import Foundation

public protocol ProjectValidatorProtocol {
    func validate(fileURL: URL, modulesFolderURL: URL) async throws
}
