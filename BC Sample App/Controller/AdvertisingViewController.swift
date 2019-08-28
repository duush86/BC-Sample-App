//
//  VideoViewController.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 8/28/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit
import BrightcovePlayerSDK

//let kViewControllerPlaybackServicePolicyKey = "BCpkADawqM32nL1Ic9gyo3bITy-1QWVkCxdmpEw9LLw3BrW7TwxPPCaWEq5OoIRzx9E3ydeeS2uir3OOi2ziy2Dh5NjlAqavWfSjyFXkTtHB69KQkyc0-FAXel3bqWzTFdMuFXy0RjhXsecd"
//let kViewControllerAccountID = "6030890615001"

class AdvertisingViewController: UIViewController, BCOVPlaybackControllerDelegate {
    var selectedDemo: Demo?
    
    @IBOutlet weak var videoContainerView: UIView!
    
    let sharedSDKManager = BCOVPlayerSDKManager.shared()
    let playbackService = BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)!
    let playbackController :BCOVPlaybackController
    
    required init?(coder aDecoder: NSCoder) {
        playbackController = (sharedSDKManager?.createPlaybackController())!
        
        super.init(coder: aDecoder)
        
        playbackController.analytics.account = kViewControllerAccountID // Optional
        
        playbackController.delegate = self
        playbackController.isAutoAdvance = true
        playbackController.isAutoPlay = true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadVideo()
        
    }
    
    func requestContentFromPlaybackService() {
        playbackService.findVideo(withVideoID: selectedDemo?.content_id, parameters: nil) { (video: BCOVVideo?, jsonResponse: [AnyHashable: Any]?, error: Error?) -> Void in
            
            if let v = video {
                self.playbackController.setVideos([v] as NSArray)
            } else {
                print("ViewController Debug - Error retrieving video: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedDemo?.name
    }
    
    
    func loadVideo(){
        
        guard let playerView = BCOVPUIPlayerView(playbackController: self.playbackController, options: nil, controlsView: BCOVPUIBasicControlView.withVODLayout()) else {
            return
        }
        self.videoContainerView.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: self.videoContainerView.topAnchor),
            playerView.rightAnchor.constraint(equalTo: self.videoContainerView.rightAnchor),
            playerView.leftAnchor.constraint(equalTo: self.videoContainerView.leftAnchor),
            playerView.bottomAnchor.constraint(equalTo: self.videoContainerView.bottomAnchor)
            ])
        
        playerView.playbackController = playbackController
        
        requestContentFromPlaybackService()
    }
}
