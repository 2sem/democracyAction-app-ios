import ProjectDescription
import ProjectDescriptionHelpers

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
                    "SKAdNetworkItems": [],
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
            scripts: [
                .post(script: "/bin/sh \"${SRCROOT}/Scripts/merge_skadnetworks.sh\"",
                      name: "Merge SKAdNetworkItems",
                      inputPaths: ["$(SRCROOT)/Resources/Plists/skNetworks.plist"],
                      outputPaths: []),
            ],
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
