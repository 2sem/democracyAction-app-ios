import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "DynamicThirdParty",
    targets: [
        .target(
            name: "DynamicThirdParty",
            destinations: .iOS,
            product: .framework,
            bundleId: .appBundleId.appending(".thirdparty.dynamic"),
            deploymentTargets: .iOS("18.0"),
            dependencies: [
                .external(name: "SDWebImage"),
                .external(name: "FirebaseCrashlytics"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseMessaging"),
                .external(name: "FirebaseRemoteConfig"),       
            ]
        ),
    ]
)
