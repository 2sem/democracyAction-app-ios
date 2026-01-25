//
//  SwiftUIAdManager.swift
//  App
//
//  Created for SwiftUI AdMob migration
//

import SwiftUI
import GoogleMobileAds
import GADManager
import AppTrackingTransparency

class SwiftUIAdManager: NSObject, ObservableObject {
    static var shared: SwiftUIAdManager?
    @Published var isReady: Bool = false
    @Published var canShowFirstTime: Bool = false

    private var manager: GADManager<GADUnitName>?

    #if DEBUG
    var testUnits: [GADUnitName] {
        [.full, .infoBottom, .favBottom, .personListNative]
    }
    #else
    var testUnits: [GADUnitName] { [] }
    #endif

    func setup() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        self.manager = GADManager<GADUnitName>(window)
        
        manager?.delegate = self
        isReady = true
    }
    
    // MARK: - Testing Flags
    func isTesting(unit: GADUnitName) -> Bool {
        return testUnits.contains(unit)
    }

    func prepare(interstitialUnit unit: GADUnitName, interval: TimeInterval) {
            manager?.prepare(interstitialUnit: unit, isTesting: self.isTesting(unit: unit), interval: interval)
    }
    
    func prepare(openingUnit unit: GADUnitName, interval: TimeInterval) {
        manager?.prepare(openingUnit: unit, isTesting: self.isTesting(unit: unit), interval: interval)
    }

    @MainActor
    @discardableResult
    func show(unit: GADUnitName) async -> Bool {
        await withCheckedContinuation { continuation in
            guard let manager else {
                continuation.resume(returning: false)
                return
            }

            manager.show(unit: unit, isTesting: self.isTesting(unit: unit),
                            viewController: UIApplication.shared.keyRootViewController?.presentedViewController ) { unit, _,result  in
                continuation.resume(returning: result)
            }
        }
    }

    func createAdLoader(forUnit unit: GADUnitName, options: [NativeAdViewAdOptions] = []) -> AdLoader? {
        return manager?.createNativeLoader(forAd: unit, isTesting: self.isTesting(unit: unit))
    }

    func requestAppTrackingIfNeed() async -> Bool {
        guard !DADefaults.AdsTrackingRequested else {
            return true
        }

        if #available(iOS 14, *) {
            let status = await ATTrackingManager.requestTrackingAuthorization()
            DADefaults.AdsTrackingRequested = true
            return status == .authorized
        }

        DADefaults.AdsTrackingRequested = true
        return true
    }
}

// MARK: - GADManagerDelegate
extension SwiftUIAdManager: GADManagerDelegate {
    typealias E = GADUnitName

    func GAD<E>(manager: GADManager<E>, lastPreparedTimeForUnit unit: E) -> Date {
        return DADefaults.LastOpeningAdPrepared
    }

    func GAD<E>(manager: GADManager<E>, updateLastPreparedTimeForUnit unit: E, preparedTime time: Date) {
        DADefaults.LastOpeningAdPrepared = time
    }

    func GAD<E>(manager: GADManager<E>, lastShownTimeForUnit unit: E) -> Date {
        let now = Date()
        if DADefaults.LastFullADShown > now {
            DADefaults.LastFullADShown = now
        }
        return DADefaults.LastFullADShown
    }

    func GAD<E>(manager: GADManager<E>, updatShownTimeForUnit unit: E, showTime time: Date) {
        DADefaults.LastFullADShown = time
    }
}
