import ProjectDescription
import ProjectDescriptionHelpers

let skAdNetworks: [Plist.Value] = ["cstr6suwn9",
                                   "4fzdc2evr5",
                                   "2fnua5tdw4",
                                   "ydx93a7ass",
                                   "5a6flpkh64",
                                   "p78axxw29g",
                                   "v72qych5uu",
                                   "c6k4g5qg8m",
                                   "s39g8k73mm",
                                   "3qy4746246",
                                   "3sh42y64q3",
                                   "f38h382jlk",
                                   "hs6bdukanm",
                                   "prcb7njmu6",
                                   "wzmmz9fp6w",
                                   "yclnxrl5pm",
                                   "4468km3ulz",
                                   "t38b2kh725",
                                   "7ug5zh24hu",
                                   "9rd848q2bz",
                                   "n6fk4nfna4",
                                   "kbd757ywx3",
                                   "9t245vhmpl",
                                   "2u9pt9hc89",
                                   "8s468mfl3y",
                                   "av6w8kgt66",
                                   "klf5c3l5u5",
                                   "ppxm28t8ap",
                                   "424m5254lk",
                                   "uw77j35x4d",
                                   "e5fvkxwrpn",
                                   "zq492l623r",
                                   "3qcr597p9d"
    ]
    .map{ .dictionary(["SKAdNetworkIdentifier" : "\($0).skadnetwork"]) }

let project = Project(
    name: "App",
    options: .options(defaultKnownRegions: ["ko"],
                         developmentRegion: "ko"),
    packages: [
        .remote(url: "https://github.com/2sem/GADManager",
                requirement: .upToNextMajor(from: "1.3.3")),
    ],
    settings: .settings(configurations: [
        .debug(
            name: "Debug",
            xcconfig: "Configs/debug.xcconfig"),
        .release(
            name: "Release",
            xcconfig: "Configs/release.xcconfig")
    ]),
    targets: [
        .target(
            name: "App",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: .appBundleId,
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIMainStoryboardFile": "Main",
                    "UIUserInterfaceStyle": "Light",
                    "GADApplicationIdentifier": "ca-app-pub-9684378399371172~5739040449",
                    "GADUnitIdentifiers": ["InfoBottom" : "ca-app-pub-9684378399371172/7215773643",
                                           "FavBottom" : "ca-app-pub-9684378399371172/7127499644",
                                           "FullAd" : "ca-app-pub-9684378399371172/1169240044"],
                    "Itunes App Id": "1243863489",
                    "NSUserTrackingUsageDescription": "맞춤형 광고 허용을 통해 개발자에게 더많은 수익을 기부할 수 있습니다.",
                    "SKAdNetworkItems": .array(skAdNetworks),
                    "ITSAppUsesNonExemptEncryption": "NO",
                    "CFBundleShortVersionString": "${MARKETING_VERSION}",
                    "CFBundleDisplayName": "문자행동",
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "CFBundleURLTypes": .array([[
                        "CFBundleTypeRole": "Editor",
                        "CFBundleURLSchemes": .array(["fb301484613596142"])
                    ], [
                        "CFBundleTypeRole": "Editor",
                        "CFBundleURLSchemes": .array(["kakao17b433ae9a9c34394a229a2b1bb94a58"])
                    ]]),
                    "FacebookAppID": "301484613596142",
                    "FacebookDisplayName": "문자행동",
                    "KAKAO_APP_KEY": "17b433ae9a9c34394a229a2b1bb94a58",
                    "LSApplicationQueriesSchemes": .array(["kakaotalk-5.9.7",
                                                          "kakao17b433ae9a9c34394a229a2b1bb94a58",
                                                          "kakaolink",
                                                          "fb",
                                                          "fbapi",
                                                          "fb-message-api",
                                                          "fbauth2"]),
                ]
            ),
            sources: ["Sources/**"],
            resources: [.glob(pattern: "Resources/**",
                              excluding: [
                                "Resources/Images/photos/*",
                                "Resources/Databases/DAModel.xcdatamodeld/**"
                              ]),
                        .folderReference(path: "Resources/Images/photos")],
            dependencies: [
                .Projects.ThirdParty,
                .Projects.DynamicThirdParty,
                .package(product: "GADManager", type: .runtime),
            ]
        ),
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: .appBundleId.appending(".tests"),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "App")]
        ),
    ]
)
