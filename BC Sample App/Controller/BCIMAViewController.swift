//
//  VideoViewController.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 8/28/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit
import BrightcovePlayerSDK
import BrightcoveIMA
import GoogleInteractiveMediaAds

class BCIMAViewController: UIViewController {
    
    @IBOutlet weak var videoContainerView: UIView!
    var selectedDemo: Demo?

    private lazy var playerView: BCOVPUIPlayerView? = {
        
        let options = BCOVPUIPlayerViewOptions()
        
        options.presentingViewController = self
        
        // Create PlayerUI views with normal VOD controls.
        
        let controlView = BCOVPUIBasicControlView.withVODLayout()
        
        guard let _playerView = BCOVPUIPlayerView(playbackController: nil, options: options, controlsView: controlView) else {
        
            return nil
        
        }
        
        // Add to parent view
        self.videoContainerView.addSubview(_playerView)
        
        _playerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        
            _playerView.topAnchor.constraint(equalTo: self.videoContainerView.topAnchor),
            
            _playerView.rightAnchor.constraint(equalTo: self.videoContainerView.rightAnchor),
            
            _playerView.leftAnchor.constraint(equalTo: self.videoContainerView.leftAnchor),
            
            _playerView.bottomAnchor.constraint(equalTo: self.videoContainerView.bottomAnchor)
            
            ])
        
        return _playerView
        
    }()
    
    private lazy var playbackController: BCOVPlaybackController? = {
        
        let imaSettings = IMASettings()
        
        imaSettings.ppid = imaPublishID
        
        imaSettings.language = imaLanguage
        
        let renderSettings = IMAAdsRenderingSettings()
        
        renderSettings.webOpenerPresentingController = self
        
        renderSettings.webOpenerDelegate = self
        
        // BCOVIMAAdsRequestPolicy provides methods to specify VAST or VMAP/Server Side Ad Rules. Select the appropriate method to select your ads policy.
        let adsRequestPolicy = BCOVIMAAdsRequestPolicy.videoPropertiesVMAPAdTagUrl()
        
        // BCOVIMAPlaybackSessionDelegate defines -willCallIMAAdsLoaderRequestAdsWithRequest:forPosition: which allows us to modify the IMAAdsRequest object
        // before it is used to load ads.
        let imaPlaybackSessionOptions = [kBCOVIMAOptionIMAPlaybackSessionDelegateKey: self]
        
        guard let _playbackController = BCOVPlayerSDKManager.shared()?.createIMAPlaybackController(
                                         with: imaSettings,
                                         adsRenderingSettings: renderSettings,
                                         adsRequestPolicy: adsRequestPolicy,
                                         adContainer: playerView?.contentOverlayView,
                                         companionSlots: nil,
                                         viewStrategy: nil,
                                         options: imaPlaybackSessionOptions)
                        else {
                                return nil
                        }
        
        _playbackController.delegate = self
        
        _playbackController.isAutoAdvance = true
        
        _playbackController.isAutoPlay = true
        
        self.playerView?.playbackController = _playbackController
        
        // Creating a playback controller based on the above code will create
        // VMAP / Server Side Ad Rules. These settings are explained in BCOVIMAAdsRequestPolicy.h.
        // If you want to change these settings, you can initialize the plugin like so:
        //
        // let adsRequestPolicy = BCOVIMAAdsRequestPolicy.init(vmapAdTagUrl: IMAConfig.VMAPResponseAdTag)
        //
        // or for VAST:
        //
        // let policy = BCOVCuePointProgressPolicy.init(processingCuePoints: .processFinalCuePoint, resumingPlaybackFrom: .fromContentPlayhead, ignoringPreviouslyProcessedCuePoints: false)
        //
        // let adsRequestPolicy = BCOVIMAAdsRequestPolicy.init(vastAdTagsInCuePointsAndAdsCuePointProgressPolicy: policy)
        //
        // _playbackController = BCOVPlayerSDKManager.shared()?.createIMAPlaybackController(with: imaSettings, adsRenderingSettings: renderSettings, adsRequestPolicy: adsRequestPolicy, adContainer: playerView?.contentOverlayView, companionSlots: nil, viewStrategy: nil, options: imaPlaybackSessionOptions)
        //
        
        return _playbackController
    }()
    
    private lazy var playbackService: BCOVPlaybackService = {
       
        return BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)
    
    }()
    
    private var notificationReceipt: AnyObject?
   
    private var adIsPlaying = false
    
    private var isBrowserOpen = false
    
    // MARK: - View Lifecyle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let _ = playerView
        
        let _ = playbackController
        
        resumeAdAfterForeground()
        
        requestContentFromPlaybackService()
    }
    
    // MARK: - Misc
    
    private func resumeAdAfterForeground() {
        // When the app goes to the background, the Google IMA library will pause
        // the ad. This code demonstrates how you would resume the ad when entering
        // the foreground.
        
        notificationReceipt = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] (notificatin: Notification) in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.adIsPlaying && !strongSelf.isBrowserOpen {
                strongSelf.playbackController?.resumeAd()
            }
        }
    }
    
    private func requestContentFromPlaybackService() {
        
        // In order to play back content, we are going to request a playlist from the
        // playback service (Video Cloud Playback API). The data from the service does
        // not have the required VMAP tag on the video, so this code demonstrates how
        // to update a playlist to set the ad tags on the video. You are responsible
        // for determining where the ad tag should originate from. We advise that if
        // you choose to hard code it into your app, that you provide a mechanism to
        // update it without having to submit an update to your app.
        
        
        playbackService.findVideo(withVideoID: selectedDemo?.content_id, parameters: nil) { (video: BCOVVideo?, jsonResponse: [AnyHashable: Any]?, error: Error?) -> Void in
            
            if let v = video {
                
                let updatedVideo: BCOVVideo = v.updateVideo(withVMAPTag: imaAdTagURL)
                self.playbackController?.setVideos([updatedVideo] as NSArray)
            
            } else {
            
                print("ViewController Debug - Error retrieving video: \(error?.localizedDescription ?? "unknown error")")
            
            }
        }
        
    }
    
}

// MARK: - BCOVPlaybackControllerDelegate

extension BCIMAViewController: BCOVPlaybackControllerDelegate {
    
    func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        print("ViewController Debug - Advanced to new session.")
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, playbackSession session: BCOVPlaybackSession!, didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {
        // Ad events are emitted by the BCOVIMA plugin through lifecycle events.
        // The events are defined BCOVIMAComponent.h.
        
        let type = lifecycleEvent.eventType
        
        if type == kBCOVIMALifecycleEventAdsLoaderLoaded {
            print("ViewController Debug - Ads loaded.")
            
            // When ads load successfully, the kBCOVIMALifecycleEventAdsLoaderLoaded lifecycle event
            // returns an NSDictionary containing a reference to the IMAAdsManager.
            guard let adsManager = lifecycleEvent.properties[kBCOVIMALifecycleEventPropertyKeyAdsManager] as? IMAAdsManager else {
                return
            }
            
            // Lower the volume of ads by half.
            adsManager.volume = adsManager.volume / 2.0
            let volumeString = String(format: "%0.1", adsManager.volume)
            print("ViewController Debug - IMAAdsManager.volume set to \(volumeString)")
            
        } else if type == kBCOVIMALifecycleEventAdsManagerDidReceiveAdEvent {
            
            guard let adEvent = lifecycleEvent.properties["adEvent"] as? IMAAdEvent else {
                return
            }
            
            switch adEvent.type {
            case .STARTED:
                print("ViewController Debug - Ad Started.")
                adIsPlaying = true
            case .COMPLETE:
                print("ViewController Debug - Ad Completed.")
                adIsPlaying = false
            case .ALL_ADS_COMPLETED:
                print("ViewController Debug - All ads completed.")
            default:
                break
            }
        }
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, playbackSession session: BCOVPlaybackSession!, didEnter adSequence: BCOVAdSequence!) {
        // Hide all controls for ads (so they're not visible when full-screen)
        playerView?.controlsContainerView.alpha = 0.0
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, playbackSession session: BCOVPlaybackSession!, didExitAdSequence adSequence: BCOVAdSequence!) {
        // Show all controls when ads are finished.
        playerView?.controlsContainerView.alpha = 1.0
    }
    
}

// MARK: - BCOVIMAPlaybackSessionDelegate

extension ViewController: BCOVIMAPlaybackSessionDelegate {
    
    func willCallIMAAdsLoaderRequestAds(with adsRequest: IMAAdsRequest!, forPosition position: TimeInterval) {
        // for demo purposes, increase the VAST ad load timeout.
        adsRequest.vastLoadTimeout = 3000.0
        let timeoutStringFormat = String(format: "%.1", adsRequest.vastLoadTimeout)
        print("ViewController Debug - IMAAdsRequest.vastLoadTimeout set to \(timeoutStringFormat) milliseconds.")
    }
    
}

// MARK: - IMAWebOpenerDelegate

extension BCIMAViewController: IMAWebOpenerDelegate {
    
    func webOpenerDidClose(inAppBrowser webOpener: NSObject!) {
        // Called when the in-app browser has closed.
        playbackController?.resumeAd()
    }
    
}
