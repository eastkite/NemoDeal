//
//  AdService.swift
//  modoohotdeal
//
//  Created by baedy on 2020/01/03.
//  Copyright © 2020 baedy. All rights reserved.
//

import Cartography
import GoogleMobileAds
import UIKit

class AdService: NSObject {
    
    private static var sharedService : AdService = {
        let service = AdService()
        service.serviceInit()
        return service
    }()
    
    class func shared() -> AdService{
        
        return sharedService
    }
    
    class func sharedWithoutInit() -> AdService{
        return sharedService
    }
    
    // 리워드 광고
    var rewardAd : GADRewardedAd?
    private var rewardCloseHandler:(() -> Void)?
    var coin : GADAdReward?
    
    // 전면 광고
    var interstitialView: GADInterstitial!
    var interstitialCloseHandler: (() -> Void)?
    var interstitialTimer : Timer?
    var isTenMinute : Bool = true
    
    // 네이티브 광고
    var adLoader: GADAdLoader!
    var nativeAdView: GADUnifiedNativeAdView!
    var heightConstraint : NSLayoutConstraint?
    
    // 배너 광고
    var defaultImageView : UIImageView?
    
    static let bannerAdId       = "ca-app-pub-6899587778873867/1658816390"
    static let interstitialAdId = "ca-app-pub-6899587778873867/2447980427"
    static let nativeAdId       = "ca-app-pub-6899587778873867/6973069860"
    static let rewardAdId       = "ca-app-pub-6899587778873867/8749185968"
    
    let dispatchGroup = DispatchGroup()
    
    //공용
    private var adContainer = [UIView]()
    
    // nativeAd
    private var nativeAdType : adType?
    private weak var nativeAdVC : UIViewController?
    
    private var intersVC : UIViewController?
    private var tapCloseActionHandler:(() -> Void)?
    
    func serviceInit(){
        self.interstitialAdInit()
        self.rewardLoad()
    }
    
}

// 배너 광고
extension AdService : GADBannerViewDelegate {
    
    func bannerAdInit(containerView : UIView) {
        
        let bannerView: GADBannerView = GADBannerView()
        
        bannerView.adSize = GADAdSizeFromCGSize(containerView.frame.size)
        bannerView.rootViewController = UIApplication.shared.topViewController
        bannerView.adUnitID = AdService.bannerAdId
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        containerView.addSubview(bannerView)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        defaultImageView?.image = nil
    }
    
    // 2순위 세팅 (300 높이 광고)
    func banner300Init(adView : UIView, defaultImageView : UIImageView){
        self.defaultImageView = defaultImageView
        
        let bannerView: GADBannerView = GADBannerView()
        
        bannerView.adSize = GADAdSizeFromCGSize(adView.frame.size)
        bannerView.rootViewController = UIApplication.shared.topViewController
        bannerView.adUnitID = AdService.bannerAdId
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        adView.addSubview(bannerView)
        
        constrain(adView, bannerView){ ad , banner in
            banner.centerY == ad.centerY
            banner.centerX == ad.centerX
        }
    }
    
}

// 리워드 광고
extension AdService : GADRewardedAdDelegate {
    
    func rewardLoad(){
        rewardAd = GADRewardedAd.init(adUnitID: AdService.rewardAdId)
        self.dispatchGroup.enter()
        
        let request = GADRequest()
        
        rewardAd?.load(request, completionHandler: {[weak self] error in
            guard let `self` = self else { return }
            
            self.dispatchGroup.leave()
            
            if error != nil{
                // 에러가 있으면
                Log.e("리워드 로드 못함")
            }else{
                // 정상 로드
                Log.d("리워드 로드 함")
            }
        })
        
    }
    
    func rewardInit(withHandler handler: @escaping (()->Void)){
        self.timerDeinit()
        self.rewardCloseHandler = handler
        LoadingIndicatorPresenter.default.startLoading()
        
        dispatchGroup.notify(queue: .main){ [weak self] in
            guard let `self` = self else { return }
            LoadingIndicatorPresenter.default.stopLoading()
            if self.rewardAd?.isReady ?? false , let topVC = UIApplication.shared.topViewController{
                Log.d("리워드 광고 show")
                self.rewardAd?.present(fromRootViewController: topVC, delegate: self)
            }else{
                Log.d("리워드 광고 로드 못함")
            }
        }
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        Log.d("@@@@@@@@@@@@@@reward : \(reward.type)")
        if reward.type == "Reward" || reward.type == "coin"{
            self.coin = reward
        }
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        /// Tells the delegate that the rewarded ad was dismissed.
        rewardLoad()
        if let handelr = rewardCloseHandler, let _ = self.coin{
            // 핸들러 실행
            handelr()
        }
        self.rewardCloseHandler = nil
        self.coin = nil
    }
    
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        /// Tells the delegate that the rewarded ad was presented.
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        /// Tells the delegate that the rewarded ad failed to present.
        rewardLoad()
        if let handelr = rewardCloseHandler{
            // 핸들러 실행
            handelr()
            rewardCloseHandler = nil
        }
    }
}


// 전면 광고
extension AdService : GADInterstitialDelegate {
    
    func timerDeinit(){
        // 토종비결, 궁합 새로 볼 때 타이머 초기화 하여 컨텐츠 별로 전면광고 10분 타이머 재 생성
        interstitialTimer = nil
        isTenMinute = true
    }
    
    func interstitialAdInit() {
        
        interstitialView = GADInterstitial(adUnitID: AdService.interstitialAdId)
        interstitialView.delegate = self
        let request = GADRequest()
        interstitialView.load(request)
    }
    
    func loadInterstitialAd(withHandler handler: @escaping (()->Void)) {
        if isTenMinute {
            self.interstitialCloseHandler = handler
            if let currentVC = UIApplication.shared.topViewController{
                interstitialView.present(fromRootViewController: currentVC)
            }
            
            if let _ = interstitialTimer{}else{
                interstitialTimer = Timer(timeInterval: 600, repeats: true, block: {[weak self] _ in
                    guard let `self` = self else { return }
                    self.isTenMinute = true
                })
            }
        }else{
            handler()
        }
    }
    
    // 전면 광고를 닫은 후, 다시 클릭했을때 광고 뜨게 하기 위함
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        isTenMinute = false
        
        if let handler = interstitialCloseHandler{
            handler()
            interstitialCloseHandler = nil
        }
        interstitialAdInit()
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        Log.d("삽입형 광고 로딩 완료 \(interstitialView.isReady)")
        
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        if let handler = interstitialCloseHandler{
            handler()
            interstitialCloseHandler = nil
        }
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}

// 네이티브 광고
extension AdService : GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate, GADUnifiedNativeAdDelegate, GADVideoControllerDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        
        nativeAdView.nativeAd = nativeAd
        nativeAd.delegate = self
        nativeAd.mediaContent.videoController.delegate = self
        
        if let controller = nativeAd.videoController, controller.hasVideoContent() {
            controller.delegate = self
        }
        
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
    }
    
    func nativeAdInit(setAdView: GADUnifiedNativeAdView) {
        
        adLoader = GADAdLoader(adUnitID: AdService.nativeAdId, rootViewController: UIApplication.shared.topViewController,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
        
        
        (setAdView.callToActionView as? UIButton)?.titleLabel?.adjustsFontSizeToFitWidth = true
        (setAdView.callToActionView as? UIButton)?.titleLabel?.numberOfLines = 1
        (setAdView.callToActionView as? UIButton)?.titleLabel?.minimumScaleFactor = 0.5
        
        nativeAdView = setAdView
        
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad was shown.
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad was clicked on.
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad will present a full screen view.
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad will dismiss a full screen view.
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad did dismiss a full screen view.
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
        // The native ad will cause the application to become inactive and
        // open a new application.
    }
    
}

enum adType{
    case nativeAd, height300Ad, nativeBannerAd, intersAd
}
