import PackageDescription

let package = Package(
    name: "YAJL",
    targets: [
        Target(name: "YAJL", dependencies: ["CYAJL"]),
        Target(name: "CYAJL")
    ]
)
