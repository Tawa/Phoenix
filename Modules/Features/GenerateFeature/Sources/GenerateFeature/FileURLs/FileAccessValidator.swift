import Foundation

protocol FileAccessValidatorProtocol {
    func hasAccess(to url: URL) -> Bool
}

struct FileAccessValidator: FileAccessValidatorProtocol {
    func hasAccess(to url: URL) -> Bool {
        FileManager.default.isDeletableFile(atPath: url.path)
    }
}
