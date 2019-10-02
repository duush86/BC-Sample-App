//
//  VideoViewController.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 8/28/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit
import BrightcovePlayerSDK
import SwiftyJSON

class OfflineViewController: UIViewController, BCOVPlaybackControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
  
    
    
    @IBOutlet weak var videoContainerView: UIView!
    
    var selectedDemo: Demo?
        
    var playlistToWorkOffline: [Video] = []
    
    @IBOutlet weak var offlineTableView: UITableView!
    
    fileprivate var tasks = [URLSessionTask]()
    
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
        //self.playerView?.overlayView.addSubview(overlayView)

        
        
        return _playbackController
    }()
    
    
    
    private lazy var playbackService: BCOVPlaybackService = {
        return BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        offlineTableView.delegate = self
        
        offlineTableView.dataSource = self
        
        offlineTableView.prefetchDataSource = self
        
        offlineTableView.allowsSelection = false
        
        offlineTableView.separatorStyle = .none
        
        let _ = playerView
        
        let _ = playbackController
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        requestContentFromPlaybackService()
    
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return playlistToWorkOffline.count

    }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
        let offlineCell = tableView.dequeueReusableCell(withIdentifier: "OfflineVideos", for: indexPath) as! OfflineTableViewCell
          
          let videoName = playlistToWorkOffline[indexPath.row].bcTitle
          
          offlineCell.videoTitle.text = videoName
        
          var videoDuration = playlistToWorkOffline[indexPath.row].bcVideoDuration

          if let image = playlistToWorkOffline[indexPath.row].thumbnailImage {

            offlineCell.videoThumbnail?.image = image

          } else {

            offlineCell.videoThumbnail.image = UIImage(named: "image-not-found.jpg")
            downloadImageForVideo(forVideo: playlistToWorkOffline[indexPath.row], onIndex: indexPath.row)


          }

          videoDuration = videoDuration / 1000.0


          if videoDuration < 60.0 {

            offlineCell.videoDuration.text = String(videoDuration.rounded())+" seconds"

          } else if videoDuration > 60.0 {

              videoDuration = videoDuration / 60.0

            offlineCell.videoDuration.text = String(videoDuration.rounded())+" minute(s)"

          }
          
        if playlistToWorkOffline[indexPath.row].isOffline == true {
            
            offlineCell.isDownloable.text = "Available Offline!"
            offlineCell.downloadButton.isEnabled = true

            
            
        } else {
            
            offlineCell.isDownloable.text = "This video is not available for download"
            offlineCell.downloadButton.isEnabled = false
        }
        
        offlineCell.downloadButton.tag = indexPath.row
            
          return offlineCell
      }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        offlineTableView.deselectRow(at: indexPath, animated: false)
//
//    }
      
     func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
         
           indexPaths.forEach { self.downloadImageForVideo(forVideo: playlistToWorkOffline[$0.row], onIndex: $0.row) }

       }
       
       func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
           indexPaths.forEach { self.cancelDownloadingImageForVideo(forVideo:  playlistToWorkOffline[$0.row], onIndex: $0.row) }

       }

    
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
                                                 withThumbnailImage: nil,
                                                 withOfflineValue: _video.canBeDownloaded)
                     
                        self?.playlistToWorkOffline.append(video)
                    }
                    
                }
                
                self!.setInitialVideoAndRefreshTable()
            
            }
            
            if let error = error {
            
                print("Error retrieving video: \(error.localizedDescription)")
            
            }
        }
    }
    
    private func setInitialVideoAndRefreshTable(){
          
        offlineTableView.reloadData()
 
    }
    
    private func requestVideoToPlay() {
        
  
        
        playbackService.findVideo(withVideoID: selectedDemo?.content_id, parameters: nil) { (video: BCOVVideo?, jsonResponse: [AnyHashable: Any]?, error: Error?) -> Void in
            
            if let v = video {
                
                //self.playbackController?.setVideos([v] as NSArray)
                print("Can be downloaded? - \(v.canBeDownloaded)")
                if v.canBeDownloaded {
                    
                    
                    
                }
           
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
                    
                    self.playlistToWorkOffline[onIndex].thumbnailImage = image
                    
                    let indexPath = IndexPath(row: onIndex, section: 0)
                    
                    if self.offlineTableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                    
                        self.offlineTableView.reloadRows(at: [IndexPath(row: onIndex, section: 0)], with: .automatic)
                    
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
