// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [:]
)
#endif

let package = Package(
    name: "democracyaction",
    dependencies: [
        .package(id: "kakao.kakao-ios-sdk", from: "2.27.3"),
        .package(url: "https://github.com/2sem/LSExtensions", exact: "0.1.22"),
        .package(id: "CoreOffice.CoreXLSX", exact: "0.14.2"),
        .package(id: "firebase.firebase-ios-sdk", .upToNextMinor(from: "12.18.0")),
        .package(url: "https://github.com/2sem/GADManager", .upToNextMinor(from: "1.5.0")),
    ]
)
