// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "FirebaseCore": .framework,
        "FirebaseCoreInternal": .framework,
        "FirebaseCoreExtension": .framework,
        "FirebaseInstallations": .framework,
        "FirebaseCrashlytics": .framework,
        "FirebaseSessions": .framework,
        "FirebaseRemoteConfig": .framework,
        "FirebaseRemoteConfigInterop": .framework,
        "FirebaseABTesting": .framework,
        "FirebaseSharedSwift": .framework,
        "FirebaseMessaging": .framework,
        "FirebaseAnalytics": .framework,
        "GoogleUtilities": .framework,
        "GoogleDataTransport": .framework,
        "nanopb": .framework,
        "FBLPromises": .framework,
        "GoogleAppMeasurement": .framework,
        "GoogleAppMeasurementIdentitySupport": .framework,
    ]
)
#endif

let package = Package(
    name: "democracyaction",
    dependencies: [
        .package(id: "kakao.kakao-ios-sdk", from: "2.27.3"),
        .package(url: "https://github.com/jdg/MBProgressHUD.git", from: "1.2.0"),
        .package(url: "https://github.com/2sem/DownPicker", branch: "spm"),
        .package(url: "https://github.com/2sem/LSExtensions", exact: "0.1.22"),
        .package(url: "https://github.com/CosmicMind/Material", from: "3.1.8"),
        .package(url: "https://github.com/2sem/LProgressWebViewController", from: "3.1.0"),
        .package(id: "krzyzanowskim.CryptoSwift", from: "1.10.0"),
        .package(id: "CoreOffice.CoreXLSX", exact: "0.14.2"),
        .package(id: "facebook.facebook-ios-sdk", from: "18.0.3"),
        .package(id: "SwipeCellKit.SwipeCellKit", from: "2.7.1"),
        .package(id: "SDWebImage.SDWebImage", from: "5.21.7"),
        .package(id: "firebase.firebase-ios-sdk", from: "12.18.0"),
        .package(url: "https://github.com/2sem/GADManager", from: "1.5.0"),
    ]
)
