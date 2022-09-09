import DemoAppFeature
import Factory

extension Container {
    static let demoAppFeatureView = ParameterFactory { (data: DemoAppFeatureData) in
        DemoAppFeatureView(
            data: data,
            dependency: .init())
    }
}
