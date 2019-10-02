//
//  VideoViewController.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 8/28/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit
import BrightcovePlayerSDK

class VideoViewController: UIViewController, BCOVPlaybackControllerDelegate {
    
    @IBOutlet weak var videoContainerView: UIView!
    var selectedDemo: Demo?
    @IBOutlet weak var overlayView: UIView!
    
    private lazy var playerView: BCOVPUIPlayerView? = {
        let options = BCOVPUIPlayerViewOptions()
        options.presentingViewController = self
    
        let controlView = BCOVPUIBasicControlView.withVODLayout()
        
        guard let _playerView = BCOVPUIPlayerView(playbackController: nil, options: options, controlsView: controlView) else { return nil }
        
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

        guard let _playbackController =  (BCOVPlayerSDKManager.shared()?.createPlaybackController()) else { return nil }

        _playbackController.delegate = self
        _playbackController.isAutoAdvance = true
        _playbackController.isAutoPlay = true
        
        self.playerView?.playbackController = _playbackController
        self.playerView?.overlayView.addSubview(overlayView)

        
        
        
        return _playbackController
    }()
    
    
    
    private lazy var playbackService: BCOVPlaybackService = {
        return BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let _ = playerView
        let _ = playbackController
       
        requestContentFromPlaybackService()
    }
    

    @IBAction func overlayPressed(_ sender: UIButton) {
        print("user tapped")
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    
    private func requestContentFromPlaybackService() {
        
  
        
        playbackService.findVideo(withVideoID: selectedDemo?.content_id, parameters: nil) { (video: BCOVVideo?, jsonResponse: [AnyHashable: Any]?, error: Error?) -> Void in
            
            if let v = video {
                self.playbackController?.setVideos([v] as NSArray)
               // self.playbackController.
            } else {
                print("ViewController Debug - Error retrieving video: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    
        
    }
    
}
