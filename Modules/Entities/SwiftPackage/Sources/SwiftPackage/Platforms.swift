public struct Platforms: Codable, Hashable {
    public var iOSVersion: IOSVersion?
    public var macCatalystVersion: MacCatalystVersion?
    public var macOSVersion: MacOSVersion?
    public var tvOSVersion: TVOSVersion?
    public var watchOSVersion: WatchOSVersion?

    public init(
        iOSVersion: IOSVersion? = nil,
        macCatalystVersion: MacCatalystVersion? = nil,
        macOSVersion: MacOSVersion? = nil,
        tvOSVersion: TVOSVersion? = nil,
        watchOSVersion: WatchOSVersion? = nil
    ) {
        self.iOSVersion = iOSVersion
        self.macCatalystVersion = macCatalystVersion
        self.macOSVersion = macOSVersion
        self.tvOSVersion = tvOSVersion
        self.watchOSVersion = watchOSVersion
    }
}

public extension Platforms {
    static var empty: Self { .init() }

    static var macroDefault: Self {
        .init(
            iOSVersion: .v15,
            macCatalystVersion: .v13,
            macOSVersion: .v10_15,
            tvOSVersion: .v13,
            watchOSVersion: .v6
        )
    }
    
    static var metaDefault: Self {
        .init(
            iOSVersion: .v15,
            macCatalystVersion: .v13,
            macOSVersion: .v10_15,
            tvOSVersion: .v13,
            watchOSVersion: .v6
        )
    }
}
