import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "ThirdParty",
    packages: [
        .remote(url: "https://github.com/kakao/kakao-ios-sdk",
                requirement: .upToNextMajor(from: "2.22.2")),
        .remote(url: "https://github.com/jdg/MBProgressHUD.git",
                requirement: .upToNextMajor(from: "1.2.0")),
        .remote(url: "https://github.com/2sem/DownPicker",
                requirement: .branch("spm")),
        .remote(url: "https://github.com/2sem/LSExtensions",
                requirement: .exact("0.1.22")),
        .remote(url: "https://github.com/CosmicMind/Material",
                requirement: .upToNextMajor(from: "3.1.8")),
        .remote(url: "https://github.com/2sem/LProgressWebViewController",
                requirement: .upToNextMajor(from: "3.1.0")),
        .package(id: "krzyzanowskim.CryptoSwift", from: "1.8.3"),
        .package(id: "CoreOffice.CoreXLSX", exact: "0.14.1"),
        .package(id: "facebook.facebook-ios-sdk", from: "14.1.0"),
        .package(id: "SwipeCellKit.SwipeCellKit", from: "2.7.1"),
    ],
    targets: [
        .target(
            name: "ThirdParty",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: .appBundleId.appending(".thirdparty"),
            dependencies: [.package(product: "CoreXLSX"),
                           .package(product: "KakaoSDK", type: .runtime),
                           .package(product: "SwipeCellKit"),
                           .package(product: "MBProgressHUD", type: .runtime),
                           .package(product: "LSExtensions", type: .runtime),
                           .package(product: "Material", type: .runtime),
                           .package(product: "DownPicker", type: .runtime),
                           .package(product: "ProgressWebViewController", type: .runtime),
                           .package(product: "CryptoSwift"),
            ]
        ),
    ]
)
