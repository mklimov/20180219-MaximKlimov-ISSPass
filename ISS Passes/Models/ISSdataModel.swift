//
//  ISSdataModel.swift
//  ISS Passes
//
//  Created by Maxim Klimov on 2/17/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

// ISSPassInfo
struct ISSPassInfo : Codable {
    let message: String
    struct request : Codable {
        let altitude: String
        let datetime: String
        let latitude: String
        let longitude: String
        let passes: String
    }
    struct passItem : Codable {
        let risetime: TimeInterval
        let duration: Int
    }
    let response: [passItem]
    
    // getRiseTimeText
    func getRiseTimeText(index: Int) -> String {
        var valueText = ""
        let risetime = response[index].risetime
        
        // convert to Date
        let date = Date(timeIntervalSince1970: risetime)
        
        // use DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        // convert to String
        valueText = dateFormatter.string(from: date)
        
        return valueText
    }
    
    // getDurationString
    func getDurationText(index: Int) -> String {
        var valueText = ""
        let duration = response[index].duration
        
        if (duration < 60) {
            // return in seconds
            valueText = String(describing: duration) + " sec"
        }
        else if (duration < 3600) {
            // return in minutes and seconds
            valueText = String(describing: (duration / 60)) + " min "  + String(describing: (duration % 60)) + " sec"
        }
        else {
            // return in hours, minutes and seconds
            valueText = String(describing: (duration / 3600)) + " hours " + String(describing: (duration % 3600) / 60) +
                " min "  + String(describing: (duration % 60)) + " sec"
        }
        
        return valueText
    }
}

// ISSApiError
struct ISSApiError : Codable {
    let message: String
    let reason: String
}

// ISSLocationInfo
struct ISSLocationInfo : Codable {
    let message: String
    let timestamp: TimeInterval
    struct positionInfo : Codable {
        let latitude: String
        let longitude: String
    }
    let iss_position: positionInfo
}
