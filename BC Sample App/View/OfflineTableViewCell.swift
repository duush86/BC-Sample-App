//
//  OfflineTableViewCell.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 10/1/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit
import BrightcovePlayerSDK

protocol OfflineCellDelegate {
    
    func didTapDownload(index: Int)
    
    
}


class OfflineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoSize: UILabel!
    @IBOutlet weak var isDownloable: UILabel!
    @IBOutlet weak var videoDuration: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    var delegate: OfflineCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        delegate?.didTapDownload(index: sender.tag)        
    }
}
