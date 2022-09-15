import Foundation

protocol FilesURLDataStoreProtocol {
    func getModulesFolderURL(forFileURL fileURL: URL) -> URL?
    func set(modulesFolderURL: URL, forFileURL fileURL: URL)
    
    func getXcodeProjectURL(forFileURL fileURL: URL) -> URL?
    func set(xcodeProjectURL: URL, forFileURL fileURL: URL)
}

protocol DictionaryCacheProtocol {
    func get(dictionaryForKey key: String) -> [String: String]
    func set(dictionary: [String: String], forKey key: String)
}

extension UserDefaults: DictionaryCacheProtocol {
    func get(dictionaryForKey key: String) -> [String : String] {
        object(forKey: key) as? [String: String] ?? [String: String]()
    }
    
    func set(dictionary: [String : String], forKey key: String) {
        set(dictionary, forKey: key)
    }
}

class FilesURLDataStore: FilesURLDataStoreProtocol {
    let modulesFolderURLCacheKey: String = "modulesFolderURLCache"
    let xcodeProjectURLCacheKey: String = "xcodeProjectURLCache"
    
    private var modulesFolderURLCache: [String: String] {
        get { dictionaryCache.get(dictionaryForKey: modulesFolderURLCacheKey) }
        set { dictionaryCache.set(dictionary: newValue, forKey: modulesFolderURLCacheKey) }
    }

    private var xcodeProjectURLCache: [String: String] {
        get { dictionaryCache.get(dictionaryForKey: xcodeProjectURLCacheKey) }
        set { dictionaryCache.set(dictionary: newValue, forKey:xcodeProjectURLCacheKey) }
    }
    
    let dictionaryCache: DictionaryCacheProtocol
    
    init(dictionaryCache: DictionaryCacheProtocol) {
        self.dictionaryCache = dictionaryCache
    }

    func getModulesFolderURL(forFileURL fileURL: URL) -> URL? {
        modulesFolderURLCache[fileURL.path].flatMap(URL.init(string:))
    }
    
    func set(modulesFolderURL: URL, forFileURL fileURL: URL) {
        modulesFolderURLCache[fileURL.path] = modulesFolderURL.path
    }
    
    func getXcodeProjectURL(forFileURL fileURL: URL) -> URL? {
        xcodeProjectURLCache[fileURL.path].flatMap(URL.init(string:))
    }
    
    func set(xcodeProjectURL: URL, forFileURL fileURL: URL) {
        xcodeProjectURLCache[fileURL.path] = xcodeProjectURL.path
    }
}
