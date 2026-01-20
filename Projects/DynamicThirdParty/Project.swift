import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "DynamicThirdParty",
    packages: [
        .package(id: "SDWebImage.SDWebImage", from: "5.21.0"),
        .package(id: "firebase.firebase-ios-sdk", from: "11.8.1"),
    ],
    targets: [
        .target(
            name: "DynamicThirdParty",
            destinations: .iOS,
            product: .framework,
            bundleId: .appBundleId.appending(".thirdparty.dynamic"),
            dependencies: [
                .package(product: "SDWebImage"),
                .package(product: "FirebaseCrashlytics"),
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseMessaging"),
                .package(product: "FirebaseRemoteConfig"),       
            ]
        ),
    ]
)
