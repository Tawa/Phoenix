import Package

extension PackageConfiguration {
    static var contract: PackageConfiguration = .init(name: "Contract",
                                                      containerFolderName: "Contracts",
                                                      appendPackageName: true,
                                                      internalDependency: nil,
                                                      hasTests: false)
    static var implementation: PackageConfiguration = .init(name: "Implementation",
                                                            containerFolderName: nil,
                                                            appendPackageName: false,
                                                            internalDependency: "Contract",
                                                            hasTests: true)
    static var mock: PackageConfiguration = .init(name: "Mock",
                                                  containerFolderName: "Mocks",
                                                  appendPackageName: true,
                                                  internalDependency: nil,
                                                  hasTests: false)
}
