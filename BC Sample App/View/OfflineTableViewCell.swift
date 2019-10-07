//
//  OfflineTableViewCell.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 10/1/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit
import BrightcovePlayerSDK

protocol OfflineCellDelegate: class {
    
    func didTapDownload(video: BCOVVideo)
    
}


class OfflineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoSize: UILabel!
    @IBOutlet weak var isDownloable: UILabel!
    @IBOutlet weak var videoDuration: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    weak var delegate: OfflineCellDelegate?
    
    weak var videoBC: BCOVVideo?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(withVideo: BCOVVideo){
        self.videoBC = withVideo
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        if let video = videoBC {
            
            delegate?.didTapDownload(video: video)
        
        }
    }
}
