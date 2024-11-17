import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "ThirdParty",
    packages: [
        .remote(url: "https://github.com/CoreOffice/CoreXLSX",
                               requirement: .exact("0.14.1")),
        .remote(url: "https://github.com/kakao/kakao-ios-sdk",
                requirement: .upToNextMajor(from: "2.22.2")),
        .remote(url: "https://github.com/facebook/facebook-ios-sdk",
                requirement: .upToNextMajor(from: "14.1.0")),
        .remote(url: "https://github.com/SwipeCellKit/SwipeCellKit",
                requirement: .upToNextMajor(from: "2.7.1")),
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
        .remote(url: "https://github.com/krzyzanowskim/CryptoSwift",
                requirement: .upToNextMajor(from: "1.8.3")),
        .remote(url: "https://github.com/Alamofire/Alamofire",
                requirement: .upToNextMajor(from: "5.10.1")),
//        .remote(url: "https://github.com/SDWebImage/SDWebImage",
//                requirement: .upToNextMajor(from: "5.20.0")),
//        .local(path: "../../../../../spms/DownPicker")
    ],
    targets: [
        .target(
            name: "ThirdParty",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: .appBundleId.appending(".thirdparty"),
            dependencies: [.package(product: "CoreXLSX", type: .runtime),
                           .package(product: "KakaoSDK", type: .runtime),
                           .package(product: "SwipeCellKit", type: .runtime),
                           .package(product: "MBProgressHUD", type: .runtime),
                           .package(product: "LSExtensions", type: .runtime),
                           .package(product: "Material", type: .runtime),
                           .package(product: "DownPicker", type: .runtime),
                           .package(product: "ProgressWebViewController", type: .runtime),
                           .package(product: "CryptoSwift", type: .runtime),
                           .package(product: "Alamofire", type: .runtime),
            ]
        ),
    ]
)
