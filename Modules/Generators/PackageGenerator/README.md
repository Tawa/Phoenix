# PackageGenerator

This package contains the code responsible for generating a Swift Package by receiving `SwiftPackage`
as input as well as the `URL` for the directory in which the Swift Package should be generated.

It creates the Sources and Tests folders, the `Package.swift` file and the `README.md` 
Only the `Package.swift` files will be rewritten on every generate call. 
The Sources and Tests folders won't be created in case they already exist and contain at least 1 file.
The `README.md` file won't be generated in case it exists.

Its public interface is contained in the `PackageGeneratorContract` Package.
