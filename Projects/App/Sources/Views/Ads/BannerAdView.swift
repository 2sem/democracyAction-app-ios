//
//  BannerAdView.swift
//  App
//
//  Banner ad wrapper for SwiftUI
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitName: String // "InfoBottom" or "FavBottom"

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSizeForDevice())
        banner.loadUnitId(adUnitName)  // Uses existing extension
        banner.rootViewController = getRootViewController()
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("Banner ad loaded successfully")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("Banner ad failed to load: \(error.localizedDescription)")
        }
    }

    private func adSizeForDevice() -> AdSize {
        UIDevice.current.userInterfaceIdiom == .pad
            ? AdSizeFullBanner  // 728x90
            : AdSizeBanner      // 320x50
    }

    private func getRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
