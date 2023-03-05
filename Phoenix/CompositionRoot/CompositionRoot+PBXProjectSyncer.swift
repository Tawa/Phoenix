import Factory
import PBXProjectSyncer
import PBXProjectSyncerContract

extension Container {
    static let pbxProjSyncer = Factory(Container.shared) {
        PBXProjectSyncer(
            packageFolderNameProvider: packageFolderNameProvider(),
            packageNameProvider: packageNameProvider(),
            packagePathProvider: packagePathProvider(),
            projectWriter: pbxProjectWriter(),
            relativeURLProvider: relativeURLProvider()
        ) as PBXProjectSyncerProtocol
    }
    
    static let pbxProjectWriter = Factory(Container.shared) {
        PBXProjectWriter() as PBXProjectWriterProtocol
    }
}
