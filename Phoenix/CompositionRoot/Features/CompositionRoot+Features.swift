import DemoAppFeature
import Factory

extension Container {
    static let demoAppFeatureView = ParameterFactory { (data: DemoAppFeatureInput) in
        DemoAppFeatureView(
            data: data,
            dependency: .init(
                demoAppNameProvider: Container.demoAppNameProvider()
            )
        )
    }
}
