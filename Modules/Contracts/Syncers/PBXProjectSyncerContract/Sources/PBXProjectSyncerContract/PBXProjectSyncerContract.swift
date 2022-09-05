import Foundation
import PhoenixDocument

public protocol PBXProjectSyncerProtocol {
    func sync(document: PhoenixDocument, at documentURL: URL, withProjectAt pbxProjURL: URL) throws
}
