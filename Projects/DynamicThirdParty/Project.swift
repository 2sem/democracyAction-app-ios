import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "DynamicThirdParty",
    packages: [
        .package(id: "SDWebImage.SDWebImage", from: "5.21.5"),
        .package(id: "firebase.firebase-ios-sdk", from: "12.8.0"),
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
