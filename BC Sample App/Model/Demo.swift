//
//  demos.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 8/28/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import Foundation

class Demo {
    var content_id: String = ""
    var name: String = ""
    init(withName: String, withContent_id: String) {
        self.name = withName
        self.content_id = withContent_id
    }
}
