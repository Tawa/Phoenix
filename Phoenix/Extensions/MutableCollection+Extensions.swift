extension MutableCollection {
    mutating func modifyEach(_ modify: (inout Element) throws -> Void) rethrows {
        var i = startIndex
        while i != endIndex {
            try modify(&self[i])
            formIndex(after: &i)
        }

    }
}
