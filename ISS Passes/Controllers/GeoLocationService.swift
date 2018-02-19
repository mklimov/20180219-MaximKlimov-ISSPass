//
//  GeoLocationManager.swift
//  ISS Passes
//
//  Created by Maxim Klimov on 2/17/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit
import CoreLocation

// GeoLocationServiceDelegate
protocol GeoLocationServiceDelegate {
    func notifyLocationUpdated()
    func notifyLocationUpdateDidFailWithError(_ error: Error)
    func notifyLocationAddress(_ shortAddress: String)
}

// GeoLocationService
class GeoLocationService : NSObject, CLLocationManagerDelegate  {
    
    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var delegate: GeoLocationServiceDelegate?
    var _started : Bool?
    
    // BONUS
    var geocoder: CLGeocoder?
    
    // init
    override init() {
        super.init()
        
        // create locationManager
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
        // check authorizationStatus
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if (authorizationStatus == .notDetermined) {
            // request authorization again
            locationManager.requestWhenInUseAuthorization()
        }
        
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.distanceFilter = 50
        self._started = false
        
        // BONUS
        // create geocoder
        self.geocoder = CLGeocoder()
    }
    
    // startUpdatingLocation
    func startUpdatingLocation() {
        // check if it was already started
        if let started = self._started {
            if (started == true) {
                print("GeoLocationService was already started")
                return
            }
        }
        // start
        self._started = true
        print("Starting GeoLocationService")
        self.locationManager?.startUpdatingLocation()
    }
    
    // stopUpdatingLocation
    func stopUpdatingLocation() {
        // check if it was already stopped
        if let started = self._started {
            if (started == false) {
                print("GeoLocationService was already stopped")
                return
            }
        }
        // stop
        self._started = false
        print("Stopping GeoLocationService")
        self.locationManager?.stopUpdatingLocation()
    }
    
    // isLocationServiceEnabled
    func isLocationServiceEnabled() -> Bool  {
        return CLLocationManager.locationServicesEnabled()
    }
    
    // isLocationAccessDenied
    func isLocationAccessDenied() -> Bool {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        return (authorizationStatus == .denied)
    }
    
    // isRunning
    func isRunning() -> Bool
    {
        return _started!
    }
    
    //
    // CLLocationManagerDelegate methods
    //
    
    // didUpdateLocations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        // compare new location with last one
        if (self.lastLocation?.coordinate.latitude == location.coordinate.latitude &&
            self.lastLocation?.coordinate.longitude == location.coordinate.longitude && 
            self.lastLocation?.altitude == location.altitude) {
            // location wasn't changed
            return
        }
        
        // remember last location
        self.lastLocation = location
        
        // notify deligate
        if let delegate = self.delegate {
            delegate.notifyLocationUpdated()
        }
        
    }
    
    // didFailWithError
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // process error to deligate
        if let delegate = self.delegate {
            delegate.notifyLocationUpdateDidFailWithError(error)
        }
    }
    
    //
    // BONUS functions
    //
    
    // findAddressByCoordinates
    func findAddressByCoordinates(_ latitude: String, _ longitude: String)
    {
        guard let geocoder = self.geocoder else {
            return
        }
        
        guard let lat = Double(latitude) else { return }
        guard let long = Double(longitude) else { return }

        // Create Location
        let location = CLLocation(latitude: lat, longitude: long)
        
        // Geocode location
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            // process Response
            var shortAddress = ""
            if let placemarks = placemarks, let placemark = placemarks.first {
                shortAddress = ""
                if let city = placemark.locality {
                    shortAddress += "\(city)"
                }
                if let state = placemark.administrativeArea {
                    if shortAddress.count > 0 {
                        shortAddress += ", "
                    }
                    shortAddress += "\(state)"
                }
                if let country = placemark.isoCountryCode {
                    if shortAddress.count > 0 {
                        shortAddress += " "
                    }
                    shortAddress += "\(country)"
                }

            } else {
                shortAddress = "Unknown"
            }
            
            // pass to deligate
            if let delegate = self.delegate {
                delegate.notifyLocationAddress(shortAddress)
            }
        }

    }
    
    // findCoordinatesByAddress
    func findCoordinatesByAddress(_ address: String, completionHandler: @escaping (CLLocation?, Error?) -> Void)
    {
        guard let geocoder = self.geocoder else {
            return
        }
        
        // Geocode location
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            // process Response
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            var addressLocation : CLLocation? = nil
            if let placemarks = placemarks, let placemark = placemarks.first {
                if let location = placemark.location {
                    addressLocation = location
                }
                
            } else {
                addressLocation = nil
            }
            
            // pass to completionHandler
            completionHandler(addressLocation, nil)
        }
    }
    
   
}
