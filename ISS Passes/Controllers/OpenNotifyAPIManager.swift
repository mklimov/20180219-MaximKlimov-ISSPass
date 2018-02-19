//
//  OpenNotifyAPI.swift
//  ISS Passes
//
//  Created by Maxim Klimov on 2/17/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

class OpenNotifyAPIManager
{
    // endpoint Url for ISS Pass timel API
    static func endpointForISSPassInfo(_ latitude: String, _ longitude: String, _ altitude: String, _ passes: String) -> String {
        var url = "http://api.open-notify.org/iss-pass.json?lat=\(latitude)&lon=\(longitude)"
        if (altitude.isEmpty == false) {
            url += "&alt=\(altitude)"
        }
        if (passes.isEmpty == false) {
            url += "&n=\(passes)"
        }
        return url;
    }
    
    // BONUS: endpoint Url to find current ISS location
    static func endpointForISSLocation() -> String {
        return "http://api.open-notify.org/iss-now.json";
    }
    
    enum ErrorType: Error {
        case urlError(reason: String)
        case objectSerialization(reason: String)
        case dataError(reason: String)
    }
    
    // retrieveISSPassInfo
    static func retrieveISSPasses(_ latitude: String, _ longitude: String, _ altitude: String, _ passes: String,
                                    completionHandler: @escaping (ISSPassInfo?, Error?) -> Void) {

        // get url
        let endpoint = endpointForISSPassInfo(latitude, longitude, altitude, passes)
        
        // create URL
        guard let url = URL(string: endpoint) else {
            let error = ErrorType.urlError(reason: "Could not construct URL")
            completionHandler(nil, error)
            return
        }
        
        // get URLRequest
        let urlRequest = URLRequest(url: url)

        // create session
        let session = URLSession.shared
        
        // submit API request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard let responseData = data else {
                completionHandler(nil, error)
                return
            }
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                // try to decode into ISSPassInfo
                let passes = try decoder.decode(ISSPassInfo.self, from: responseData)
                completionHandler(passes, nil)
            } catch {
                do {
                    // try to decode into ISSApiError
                    let errorApi = try decoder.decode(ISSApiError.self, from: responseData)
                    // return as Error
                    let _error = ErrorType.dataError(reason: errorApi.reason)
                    completionHandler(nil, _error)
                } catch {
                    print(error)
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
    
    // retrieveISSLocation
    static func retrieveISSLocation(completionHandler: @escaping (ISSLocationInfo?, Error?) -> Void) {
        
        // get url
        let endpoint = endpointForISSLocation()
        
        // create URL
        guard let url = URL(string: endpoint) else {
            let error = ErrorType.urlError(reason: "Could not construct URL")
            completionHandler(nil, error)
            return
        }
        
        // get URLRequest
        let urlRequest = URLRequest(url: url)
        
        // create session
        let session = URLSession.shared
        
        // submit API request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard let responseData = data else {
                completionHandler(nil, error)
                return
            }
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                // try to decode into ISSLocationInfo
                let locationInfo = try decoder.decode(ISSLocationInfo.self, from: responseData)
                completionHandler(locationInfo, nil)
            } catch {
                do {
                    // try to decode into ISSApiError
                    let errorApi = try decoder.decode(ISSApiError.self, from: responseData)
                    // return as Error
                    let _error = ErrorType.dataError(reason: errorApi.reason)
                    completionHandler(nil, _error)
                } catch {
                    print(error)
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
}
