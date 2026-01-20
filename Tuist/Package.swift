// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,] 
        productTypes: [:]
    )
#endif

let package = Package(
    name: "democracyAction-app-ios",
    dependencies: [
        // .package(id: "pointfreeco.swift-composable-architecture", from: "0.1.0"),
        // Dynamic
        .package(id: "SDWebImage.SDWebImage", from: "5.21.0"),
        .package(id: "firebase.firebase-ios-sdk", from: "11.8.1"),

        // Static
        // .package(id: "Alamofire.Alamofire", from: "5.10.1"),
        .package(id: "krzyzanowskim.CryptoSwift", from: "1.8.3"),
        .package(id: "CoreOffice.CoreXLSX", exact: "0.14.1"),
        .package(id: "facebook.facebook-ios-sdk", from: "14.1.0"),
        .package(id: "SwipeCellKit.SwipeCellKit", from: "2.7.1"),
        // Add your own dependencies here:
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
    ]
)
