import ProjectDescription
import ProjectDescriptionHelpers

let skAdNetworkIDs: [String] = [
    "cstr6suwn9", "4fzdc2evr5", "2fnua5tdw4", "ydx93a7ass", "p78axxw29g",
    "v72qych5uu", "ludvb6z3bs", "cp8zw746q7", "3sh42y64q3", "c6k4g5qg8m",
    "s39g8k73mm", "wg4vff78zm", "3qy4746246", "f38h382jlk", "hs6bdukanm",
    "mlmmfzh3r3", "v4nxqhlyqp", "wzmmz9fp6w", "su67r6k2v3", "yclnxrl5pm",
    "t38b2kh725", "7ug5zh24hu", "gta9lk7p23", "vutu7akeur", "y5ghdn5j9k",
    "v9wttpbfk9", "n38lu8286q", "47vhws6wlr", "kbd757ywx3", "9t245vhmpl",
    "a2p9lx4jpn", "22mmun2rn5", "44jx6755aq", "k674qkevps", "4468km3ulz",
    "2u9pt9hc89", "8s468mfl3y", "klf5c3l5u5", "ppxm28t8ap", "kbmxgpxpgc",
    "uw77j35x4d", "578prtvx9j", "4dzt52r2t5", "tl55sbb4fm", "c3frkrj4fj",
    "e5fvkxwrpn", "8c4e2ghe7u", "3rd42ekr43", "97r2b46745", "3qcr597p9d",
    "9rd848q2bz",
]

let skAdNetworks: [Plist.Value] = skAdNetworkIDs
    .map { .dictionary(["SKAdNetworkIdentifier": .string("\($0).skadnetwork")]) }

let project = Project(
    name: "App",
    options: .options(defaultKnownRegions: ["ko"],
                         developmentRegion: "ko"),
    packages: [
        .remote(url: "https://github.com/2sem/GADManager",
                requirement: .upToNextMajor(from: "1.3.8")),
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
                    "UIUserInterfaceStyle": "Light",
                    "GADApplicationIdentifier": "ca-app-pub-9684378399371172~5739040449",
                    "GADUnitIdentifiers": ["InfoBottom" : "ca-app-pub-9684378399371172/7215773643",
                                           "FavBottom" : "ca-app-pub-9684378399371172/7127499644",
                                           "FullAd" : "ca-app-pub-9684378399371172/1169240044",
                                           "PersonListNative" : "ca-app-pub-9684378399371172/4345258981",
                                           "FavoritesNative" : "ca-app-pub-9684378399371172/1639010875",
                                           "Launch" : "ca-app-pub-9684378399371172/4596346702",
                                           ],
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
                .sdk(name: "SwiftUI", type: .framework),
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
