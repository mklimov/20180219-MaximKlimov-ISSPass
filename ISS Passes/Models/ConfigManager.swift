//
//  ConfigManager.swift
//  ISS Passes
//
//  Created by Maxim on 2/18/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

// ConfigManager
class ConfigManager {
    
    enum CoordinatesSource {
        case device
        case address
    }
    
    var passes: Int
    var refreshMapInSec : Double
    var coordinatesSource : CoordinatesSource
    
    // init
    init() {
        passes = 100
        refreshMapInSec = 5.0
        coordinatesSource = .device
        
        // NOTE: if I had more time:
        // - allow user to change config settings in app Setting
        // - persist config settings
    }
}
