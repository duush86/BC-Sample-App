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

class PlaylistViewController: UIViewController,BCOVPlaybackControllerDelegate,UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    var selectedDemo: Demo?
    
    @IBOutlet weak var playlistViewController: UITableView!
    
    @IBOutlet weak var videoView: UIView!
    
    fileprivate var tasks = [URLSessionTask]()
    
    var videosFromPlaylist: [Video] = []

    
    override func viewDidLoad() {  
        
        super.viewDidLoad()
        
        playlistViewController.delegate = self
        
        playlistViewController.dataSource = self
        
        playlistViewController.prefetchDataSource = self
        
        let _ = playerView
        
        let _ = playbackController
        
        
    }
    
    //MARK: Request content for Playlist before view loads
    override func viewWillAppear(_ animated: Bool) {
        
        requestContentFromPlaybackService()
        
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
    
    
    //MARK: Playback Service variable
    private lazy var playbackService: BCOVPlaybackService = {
     
        return BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)
    
    }()
    
    //MARK: INITIAL PLAYBACK SERVICE TO GET PLAYLIST DETAILLS
    private func requestContentFromPlaybackService() {
        
        playbackService.findPlaylist(withPlaylistID: selectedDemo?.content_id, parameters: nil) { [weak self] (plist: BCOVPlaylist?, jsonResponse: [AnyHashable:Any]?, error: Error?) in
        
            if let playlist = plist {
            
                for video in playlist.videos {
                
                    if let _video = video as? BCOVVideo {
                        
                        let video: Video = Video(withTitle: JSON(_video.properties)["name"].stringValue,
                                                 withVideoId: JSON(_video.properties)["id"].stringValue,
                                                 withVideoDuration: JSON(_video.properties)["duration"].doubleValue,
                                                 withShortDescription: nil,
                                                 withThumbnailURL: JSON(_video.properties)["thumbnail"].url,
                                                 withThumbnailImage: nil)
                        
                        self?.videosFromPlaylist.append(video)
                    }
                    
                }
                
                self!.setInitialVideoAndRefreshTable()
            
            }
            
            if let error = error {
            
                print("Error retrieving video: \(error.localizedDescription)")
            
            }
        }
    }
    
    //MARK: FILL NUMBER OF CELLS WITH THE NUMBERS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return videosFromPlaylist.count

    }
    
    //MARK: FILL CELLS WITH THE VIDEO NAMES
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        
        let playlistCell = tableView.dequeueReusableCell(withIdentifier: "videoOnPlaylist", for: indexPath) as! playlistTableViewCell
        
        let videoName = videosFromPlaylist[indexPath.row].bcTitle
        
        playlistCell.videoName.text = videoName
        
        
        var videoDuration = videosFromPlaylist[indexPath.row].bcVideoDuration
        
        if let image = videosFromPlaylist[indexPath.row].thumbnailImage {
          
            playlistCell.imageView?.image = image
            
        } else {
            
            playlistCell.imageView?.image = UIImage(named: "image-not-found.jpg")
            
            downloadImageForVideo(forVideo: videosFromPlaylist[indexPath.row], onIndex: indexPath.row)
        }
        
        videoDuration = videoDuration / 1000.0
        
        //Cases for seconds and minutes
        
        
        
        if videoDuration < 60.0 {
            
            playlistCell.videoDuration.text = String(videoDuration.rounded())+" seconds"
        
        } else if videoDuration > 60.0 {
            
            videoDuration = videoDuration / 60.0
            
            playlistCell.videoDuration.text = String(videoDuration.rounded())+" minute(s)"

        }
        
        return playlistCell
        
    }
    
    
    
    //MARK: CALL playVideoFromPlaylist WHEN A ROW is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        playVideoFromPlaylist(with: videosFromPlaylist[indexPath.row])
    
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
      
        indexPaths.forEach { self.downloadImageForVideo(forVideo: videosFromPlaylist[$0.row], onIndex: $0.row) }

    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
     
        indexPaths.forEach { self.cancelDownloadingImageForVideo(forVideo:  videosFromPlaylist[$0.row], onIndex: $0.row) }

    }
    
    
    
    //MARK: Set initial video and populate tables
    private func setInitialVideoAndRefreshTable(){
       
        playVideoFromPlaylist(with: videosFromPlaylist[0])
        
        playlistViewController.reloadData()

    }
    
    //MARK: GET THE ACTUAL VIDEO TO PLAY
    private func playVideoFromPlaylist(with video: Video){
      
        playbackService.findVideo(withVideoID: video.bcVideoId, parameters: nil) { (video: BCOVVideo?, jsonResponse: [AnyHashable: Any]?, error: Error?) -> Void in
            
            if let v = video {
              
                self.playbackController?.setVideos([v] as NSArray)
            
            } else {
            
                print("ViewController Debug - Error retrieving video: \(error?.localizedDescription ?? "unknown error")")
            
            }
        }
    }
    
    func downloadImageForVideo(forVideo: Video, onIndex: Int){
        
        let imageUrl = forVideo.thumbnailURL
        
        guard tasks.firstIndex(where: { $0.originalRequest?.url == imageUrl } ) == nil else {
            
            // we are already downloading the image, move on.
            return
        }
        let task = URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
            
            DispatchQueue.main.async {
               
                if let data = data, let image = UIImage(data: data) {
                    
                    self.videosFromPlaylist[onIndex].thumbnailImage = image
                    
                    let indexPath = IndexPath(row: onIndex, section: 0)
                    
                    if self.playlistViewController.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                    
                        self.playlistViewController.reloadRows(at: [IndexPath(row: onIndex, section: 0)], with: .automatic)
                    
                    }
                
                }
            }
            
        }
        
        task.resume()
        
        tasks.append(task)
    }
    
    func cancelDownloadingImageForVideo(forVideo: Video, onIndex: Int){
        
        let imageUrl = forVideo.thumbnailURL
        
        guard let taskIndex = tasks.firstIndex(where: { $0.originalRequest?.url == imageUrl }) else {
        
            return
        
        }
        
        let task = tasks[taskIndex]
        
        task.cancel()
        
        tasks.remove(at: taskIndex)
        
    }
}
