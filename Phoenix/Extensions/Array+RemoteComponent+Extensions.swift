import Component

extension Array where Element == RemoteComponent {
    func filtered(_ filter: String?) -> Self {
        guard let filter, !filter.isEmpty else { return self }
        return self.filter { remoteComponent in
            remoteComponent.url.lowercased().contains(filter) ||
            remoteComponent.names.contains(where: { externalDependencyName in
                externalDependencyName.name.lowercased().contains(filter) ||
                externalDependencyName.package?.lowercased().contains(filter) ?? false
            })
        }
    }
}
