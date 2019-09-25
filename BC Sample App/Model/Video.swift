//
//  Video.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 9/25/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit

struct Video {
    
    var bcTitle: String
    var bcVideoId: String
    var bcVideoDuration: Double
    var bcShortDescription: String?
    var thumbnailURL: URL?
    var thumbnailImage: UIImage?
    
    init(withTitle: String,
         withVideoId: String,
         withVideoDuration: Double,
         withShortDescription: String? = nil,
         withThumbnailURL: URL? = nil,
         withThumbnailImage: UIImage? = nil) {
        
        self.bcTitle = withTitle
       
        self.bcVideoId = withVideoId
        
        self.bcVideoDuration = withVideoDuration
        
        self.bcShortDescription = withShortDescription
        
        self.thumbnailURL = withThumbnailURL
        
        self.thumbnailImage = withThumbnailImage
        
    }
    
    
    
}
