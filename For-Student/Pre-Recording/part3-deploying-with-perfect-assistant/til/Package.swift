import PackageDescription

let package = Package(
    name: "til",
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2),        
    ]
)
