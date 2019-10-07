//
//  Protocols.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 10/3/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import Foundation
import BrightcovePlayerSDK

protocol ReloadDelegate: class {
    func reloadData()
    func reloadRow(forVideo video: BCOVVideo)
}
