import DocumentCoder
import DocumentCoderContract
import Factory

extension Container {
    static let phoenixDocumentFileWrappersDecoder = Factory(Container.shared) {
        PhoenixDocumentFileWrappersDecoder() as PhoenixDocumentFileWrappersDecoderProtocol
    }

    static let phoenixDocumentFileWrapperEncoder = Factory(Container.shared) {
        PhoenixDocumentFileWrapperEncoder(
            currentAppVersionStringProvider: currentAppVersionStringProvider()
        ) as PhoenixDocumentFileWrapperEncoderProtocol
    }
}
