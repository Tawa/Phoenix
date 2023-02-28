import Foundation

public protocol GenerateFeatureDataStoreProtocol {
    func getModulesFolderURL(forFileURL fileURL: URL) -> URL?
    func set(modulesFolderURL: URL, forFileURL fileURL: URL)
    
    func getXcodeProjectURL(forFileURL fileURL: URL) -> URL?
    func set(xcodeProjectURL: URL, forFileURL fileURL: URL)
    
    func getShouldSkipXcodeProject(forFileURL fileURL: URL) -> Bool
    func set(shouldSkipXcodeProject: Bool, forFileURL fileURL: URL)
}
