//
//  PlaylistCell.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 9/23/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit

class playlistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    
    @IBOutlet weak var videoName: UILabel!
    @IBOutlet weak var videoDuration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
