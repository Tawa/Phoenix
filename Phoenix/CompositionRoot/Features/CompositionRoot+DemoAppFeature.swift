import DemoAppFeature
import Factory

extension Container {
    // DemoAppFeature
    static let demoAppFeatureView = ParameterFactory(Container.shared) { (data: DemoAppFeatureInput) in
        DemoAppFeatureView(
            data: data,
            dependency: .init(
                demoAppGenerator: demoAppGenerator(),
                demoAppNameProvider: demoAppNameProvider(),
                packageFolderNameProvider: packageFolderNameProvider(),
                packageNameProvider: packageNameProvider(),
                pbxProjectSyncer: pbxProjSyncer()
            )
        )
    }
    
    private static let demoAppNameProvider = Factory(Container.shared) {
        DemoAppNameProvider() as DemoAppNameProviderProtocol
    }
}
