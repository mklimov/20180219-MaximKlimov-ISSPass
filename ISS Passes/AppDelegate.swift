//
//  AppDelegate.swift
//  ISS Passes
//
//  Created by Maxim Klimov on 2/17/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // services
    var configManager : ConfigManager?
    var geoLocationService: GeoLocationService?
    var wasGeoServicerunning : Bool?
    
    // didFinishLaunchingWithOptions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // create configManager
        configManager = ConfigManager()
        
        // create and start geoLocationService
        geoLocationService = GeoLocationService()
        geoLocationService?.startUpdatingLocation()
        wasGeoServicerunning = true
        
        return true
    }

    // applicationWillResignActive
    func applicationWillResignActive(_ application: UIApplication) {

    }

    // applicationDidEnterBackground
    func applicationDidEnterBackground(_ application: UIApplication) {
        // remember geo service status
        wasGeoServicerunning = geoLocationService?.isRunning()
        // stop updating locations
        geoLocationService?.stopUpdatingLocation()
    }

    // applicationWillEnterForeground
    func applicationWillEnterForeground(_ application: UIApplication) {
        if (wasGeoServicerunning != nil && wasGeoServicerunning!) {
            // re-start updating locations
            geoLocationService?.startUpdatingLocation()
        }
    }

    // applicationDidBecomeActive
    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    // applicationWillTerminate
    func applicationWillTerminate(_ application: UIApplication) {

    }


}

