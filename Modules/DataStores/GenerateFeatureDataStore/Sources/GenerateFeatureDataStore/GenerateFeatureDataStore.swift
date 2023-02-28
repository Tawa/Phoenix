import GenerateFeatureDataStoreContract
import Foundation

public protocol GenerateFeatureCacheProtocol {
    func get(dictionaryForKey key: String) -> [String: String]
    func set(dictionary: [String: String], forKey key: String)
    
    func get(boolDictionaryForKey key: String) -> [String: Bool]
    func set(boolDictionary: [String: Bool], forKey key: String)
}

extension UserDefaults: GenerateFeatureCacheProtocol {
    public func get(dictionaryForKey key: String) -> [String : String] {
        object(forKey: key) as? [String: String] ?? [String: String]()
    }
    
    public func set(dictionary: [String : String], forKey key: String) {
        set(dictionary, forKey: key)
    }
    
    public func get(boolDictionaryForKey key: String) -> [String : Bool] {
        object(forKey: key) as? [String: Bool] ?? [String: Bool]()
    }
    
    public func set(boolDictionary: [String : Bool], forKey key: String) {
        set(boolDictionary, forKey: key)
    }
}

public class GenerateFeatureDataStore: GenerateFeatureDataStoreProtocol {
    let modulesFolderURLCacheKey: String = "modulesFolderURLCache"
    let xcodeProjectURLCacheKey: String = "xcodeProjectURLCache"
    let shouldSkipXcodeProjectCacheKey: String = "shouldSkipXcodeProjectCache"
    
    private var modulesFolderURLCache: [String: String] {
        get { cache.get(dictionaryForKey: modulesFolderURLCacheKey) }
        set { cache.set(dictionary: newValue, forKey: modulesFolderURLCacheKey) }
    }

    private var xcodeProjectURLCache: [String: String] {
        get { cache.get(dictionaryForKey: xcodeProjectURLCacheKey) }
        set { cache.set(dictionary: newValue, forKey:xcodeProjectURLCacheKey) }
    }
    
    private var shouldSkipXcodeProjectCache: [String: Bool] {
        get { cache.get(boolDictionaryForKey: shouldSkipXcodeProjectCacheKey) }
        set { cache.set(boolDictionary: newValue, forKey: shouldSkipXcodeProjectCacheKey) }
    }
    
    let cache: GenerateFeatureCacheProtocol
    
    public init(dictionaryCache: GenerateFeatureCacheProtocol) {
        self.cache = dictionaryCache
    }

    public func getModulesFolderURL(forFileURL fileURL: URL) -> URL? {
        modulesFolderURLCache[fileURL.path].flatMap(URL.init(string:))
    }
    
    public func set(modulesFolderURL: URL, forFileURL fileURL: URL) {
        modulesFolderURLCache[fileURL.path] = modulesFolderURL.path
    }
    
    public func getXcodeProjectURL(forFileURL fileURL: URL) -> URL? {
        xcodeProjectURLCache[fileURL.path].flatMap(URL.init(string:))
    }
    
    public func set(xcodeProjectURL: URL, forFileURL fileURL: URL) {
        xcodeProjectURLCache[fileURL.path] = xcodeProjectURL.path
    }
    
    public func getShouldSkipXcodeProject(forFileURL fileURL: URL) -> Bool {
        shouldSkipXcodeProjectCache[fileURL.path] ?? false
    }
    
    public func set(shouldSkipXcodeProject: Bool, forFileURL fileURL: URL) {
        shouldSkipXcodeProjectCache[fileURL.path] = shouldSkipXcodeProject
    }
}

