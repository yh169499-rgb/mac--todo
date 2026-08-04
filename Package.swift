// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TodaysTodoApp",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "TodaysTodoApp", targets: ["TodaysTodoApp"])
    ],
    targets: [
        .executableTarget(name: "TodaysTodoApp"),
        .testTarget(name: "TodaysTodoAppTests", dependencies: ["TodaysTodoApp"])
    ]
)
