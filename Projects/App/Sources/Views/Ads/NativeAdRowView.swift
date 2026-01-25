//
//  NativeAdRowView.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI

// A subview that displays a native ad row with given ad unit and index, using the provided interval to determine placement.
struct NativeAdRowView: View {
    @EnvironmentObject private var adManager: SwiftUIAdManager

    let adUnit: SwiftUIAdManager.GADUnitName
    let index: Int
    let interval: Int

    var body: some View {
        if index % interval == 0 {
            NativeAdSwiftUIView(adUnit: adUnit) { nativeAd in
                SwiftUI.Group {
                    if let ad = nativeAd {
                        // Match PoliticianRow styling
                        HStack(spacing: 12) {
                            // Photo on left - match politician photo size
                            MediaViewSwiftUIView(mediaContent: ad.mediaContent)
                                .frame(width: 50, height: 65)
                                .clipShape(RoundedRectangle(cornerRadius: 4))

                            // Name on left
                            Text(ad.headline ?? "")
                                .font(.headline)
                                .fontWeight(.medium)

                            Spacer()

                            // Advertiser and CTA on right - match politician party/area layout
                            VStack(alignment: .trailing, spacing: 2) {
                                if let advertiser = ad.advertiser {
                                    Text(advertiser)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                if let cta = ad.callToAction {
                                    Text(cta)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .task {
                            await adManager.requestAppTrackingIfNeed()
                        }
                        .overlay(alignment: .topTrailing) {
                            AdMarkView()
                                .padding(.top, 2)
                        }
                    } else {
                        // Developer fallback - match politician row styling
                        HStack(spacing: 12) {
                            Image("otherapp")
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 65)
                                .clipShape(RoundedRectangle(cornerRadius: 4))

                            Text("관련주식검색기")
                                .font(.headline)
                                .fontWeight(.medium)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("개발자")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text("자세히 보기")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .onTapGesture {
                            guard let url = URL(string: "https://apps.apple.com/us/developer/young-jun-lee/id1225480114") else {
                                return
                            }
                            UIApplication.shared.open(url, options: [.universalLinksOnly : false], completionHandler: nil)
                        }
                        .overlay(alignment: .topTrailing) {
                            AdMarkView()
                                .padding(.top, 2)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Ad Mark
private struct AdMarkView: View {
    private let text: String = "Ad"
    var body: some View {
        Text(text)
            .font(.caption2)
            .bold()
            .foregroundStyle(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Color.gray.opacity(0.5))
            )
            .accessibilityLabel("Advertisement")
    }
}
