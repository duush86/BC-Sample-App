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
    @IBOutlet weak var CloseOVerlay: UIView!
    @IBOutlet weak var closeOverlayTapped: UIButton!

    
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
        self.playerView?.overlayView.addSubview(CloseOVerlay)

        
        
        return _playbackController
    }()
    
    
    
    private lazy var playbackService: BCOVPlaybackService = {
        return BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)
    }()
    
   // private lazy var contentOverViewView:

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let _ = playerView
        let _ = playbackController
        requestContentFromPlaybackService()
    }
    

    @IBAction func closeOverlayTapped(_ sender: UIButton) {
        print("user tapped")
        self.dismiss(animated: true, completion: nil)
        _ = navigationController?.popToRootViewController(animated: true)

    }
    
    private func requestContentFromPlaybackService() {
        
  
        
        playbackService.findVideo(withVideoID: selectedDemo?.content_id, parameters: nil) { [weak self] (video: BCOVVideo?, jsonResponse: [AnyHashable:Any]?, error: Error?) in
            
            if let video = video {
                
                let playlist = BCOVPlaylist(video: video)
                let updatedPlaylist = playlist?.update({ (mutablePlaylist: BCOVMutablePlaylist?) in
                    
                    guard let mutablePlaylist = mutablePlaylist else {
                        return
                    }
                    
                    var updatedVideos:[BCOVVideo] = []
                    
                    for video in mutablePlaylist.videos {
                        if let _video = video as? BCOVVideo {
                            updatedVideos.append(_video)
                        }
                    }
                    
                    mutablePlaylist.videos = updatedVideos
                    
                })
                
                if let _updatedPlaylist = updatedPlaylist {
                    self?.playbackController?.setVideos(_updatedPlaylist.videos as NSFastEnumeration)
                }
            }
            
            if let error = error {
                print("Error retrieving video: \(error.localizedDescription)")
            }
            
        }
        
    }
    
}
