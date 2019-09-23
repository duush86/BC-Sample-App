//
//  PlaylistViewController.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 9/12/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit
import BrightcovePlayerSDK
import SwiftyJSON
import SVProgressHUD


class PlaylistViewController: UIViewController,BCOVPlaybackControllerDelegate,UITableViewDataSource, UITableViewDelegate {
    
    
    var selectedDemo: Demo?
    @IBOutlet weak var playlistViewController: UITableView!
    @IBOutlet weak var videoView: UIView!
    var videosOnPlaylist: [BCOVVideo] = []
    var playlistToPlay: BCOVPlaylist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //SVProgressHUD.show()
        playlistViewController.delegate = self
        playlistViewController.dataSource = self
        let _ = playerView
        let _ = playbackController
        //SVProgressHUD.dismiss()
    }
    
    //MARK: PlayerView variable and setup
    private lazy var playerView: BCOVPUIPlayerView? = {
        let options = BCOVPUIPlayerViewOptions()
        options.presentingViewController = self
        
        let controlView = BCOVPUIBasicControlView.withVODLayout()
        
        guard let _playerView = BCOVPUIPlayerView(playbackController: nil, options: options, controlsView: controlView) else { return nil }
        
        // Add to parent view
        self.videoView.addSubview(_playerView)
        
        _playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _playerView.topAnchor.constraint(equalTo: self.videoView.topAnchor),
            _playerView.rightAnchor.constraint(equalTo: self.videoView.rightAnchor),
            _playerView.leftAnchor.constraint(equalTo: self.videoView.leftAnchor),
            _playerView.bottomAnchor.constraint(equalTo: self.videoView.bottomAnchor)
            ])
        return _playerView
    }()
    
    
    //MARK: Playbacl controller variable
    private lazy var playbackController: BCOVPlaybackController? = {
        
        guard let _playbackController =  (BCOVPlayerSDKManager.shared()?.createPlaybackController()) else { return nil }
        
        _playbackController.delegate = self
        _playbackController.isAutoAdvance = true
        _playbackController.isAutoPlay = true
        
        self.playerView?.playbackController = _playbackController        
        return _playbackController
    }()
    
    //MARK: Request content for Playlist before view loads
    override func viewWillAppear(_ animated: Bool) {
        //SVProgressHUD.init()
        requestContentFromPlaybackService()
        //SVProgressHUD.dismiss()
    }
    //MARK: Playback Service variable
    private lazy var playbackService: BCOVPlaybackService = {
        return BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)
    }()
    
    //MARK: INITIAL PLAYBACK SERVICE TO GET PLAYLIST DETAILLS
    private func requestContentFromPlaybackService() {
        var videosOnPL: [BCOVVideo] = []
         playbackService.findPlaylist(withPlaylistID: selectedDemo?.content_id, parameters: nil)
         { [weak self] (plist: BCOVPlaylist?, jsonResponse: [AnyHashable:Any]?, error: Error?) in
            if let playlist = plist {
                    for video in playlist.videos {
                        if let _video = video as? BCOVVideo {
                            videosOnPL.append(_video)
                        }
                    }
                
                self!.handleVideosToDisplay(withVideos: videosOnPL,withPlaylist: playlist)
            }
            if let error = error {
                print("Error retrieving video: \(error.localizedDescription)")
            }
            
        }
    }
    //MARK: FILL NUMBER OF CELLS WITH THE NUMBERS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videosOnPlaylist.count
    }
    //MARK: FILL CELLS WITH THE VIDEO NAMES
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let playlistCell = tableView.dequeueReusableCell(withIdentifier: "videoOnPlaylist", for: indexPath) as! playlistTableViewCell
        
        playlistCell.videoName.text = JSON(videosOnPlaylist[indexPath.row].properties)["name"].stringValue
        
        let imageData = try? Data(contentsOf: JSON(videosOnPlaylist[indexPath.row].properties)["thumbnail"].url!) //make sure your image in this url does
        
        playlistCell.videoThumbnail.image = UIImage(data: imageData!)
        
        var videoDuration = JSON(videosOnPlaylist[indexPath.row].properties)["duration"].doubleValue
        
        videoDuration = videoDuration / 1000.0
       // print("Video: \(JSON(videosOnPlaylist[indexPath.row].properties)["name"].stringValue) + duration: "+String(videoDuration))
        //Cases for seconds and minutes
        if videoDuration < 60.0 {
            
            
            playlistCell.videoDuration.text = String(videoDuration.rounded())+" seconds"
        
        } else if videoDuration > 60.0 {
            
            videoDuration = videoDuration / 60.0
            
            playlistCell.videoDuration.text = String(videoDuration.rounded())+" minute(s)"

        }
        
        //
        return playlistCell
    }
    //MARK: CALL playVideoFromPlaylist WHEN A ROW is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playVideoFromPlaylist(with: videosOnPlaylist[indexPath.row])
    }
    
    
    //MARK: COPY VIDEOS AND PLAYLIST FOR GENERAL CONSUMPTION
    private func handleVideosToDisplay(withVideos videos:  [BCOVVideo],withPlaylist playlist: BCOVPlaylist){
        videosOnPlaylist = videos
        playlistToPlay = playlist
       
        //SVProgressHUD.setContainerView(playlistViewController)
        //SVProgressHUD.show()
        playlistViewController.reloadData()
       //SVProgressHUD.dismiss()
        playVideoFromPlaylist(with: videosOnPlaylist[0])

    }
    
    //MARK: GET THE ACTUAL VIDEO TO PLAY
    private func playVideoFromPlaylist(with video:BCOVVideo){
      //  print(JSON(video.properties)["id"])
        playbackService.findVideo(withVideoID: JSON(video.properties)["id"].stringValue, parameters: nil) { [weak self] (video: BCOVVideo?, jsonResponse: [AnyHashable:Any]?, error: Error?) in
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
