//
//  ISSLocationViewController.swift
//  ISS Passes
//
//  Created by Maxim Klimov on 2/17/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit
import MapKit

// ISSLocationViewController
class ISSLocationViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // variable for retrieved ISS location ingo
    var _locationInfo : ISSLocationInfo?
    
    // map annatation to show ISS position
    var _issAnnotation: MKPointAnnotation?

    // timer to refresh ISS position
    var refreshTimer: Timer!
    
    // viewDidLoad
    override func viewDidLoad() {
        // super
        super.viewDidLoad()
        
        // configure mapView - show almost whole world map
        let span = MKCoordinateSpan.init(latitudeDelta:180.0, longitudeDelta: 360.0)
        let resd = CLLocationCoordinate2D.init(latitude:0, longitude:0)
        let region = MKCoordinateRegion.init(center: resd, span: span);
        self.mapView.setRegion(region, animated: true)
    }
    
    // viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        // super
        super.viewWillAppear(animated)
        
        // BONUS
        // update data - first time
        updateData()
        
        // create timer to call "updateData" every 5 sec
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        refreshTimer = Timer.scheduledTimer(timeInterval: TimeInterval((appDelegate.configManager?.refreshMapInSec)!),
                                            target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
    }
    
    // viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        // super
        super.viewWillDisappear(animated)
        
        // remove timer
        refreshTimer.invalidate()
    }

    // didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //
    // Private functions
    //
    
    // updateData
    @objc private func updateData() {
        // call OpenNotifyAPI
        OpenNotifyAPIManager.retrieveISSLocation(){ (locationInfo, error) in
            // check for error
            if let error = error {
                AlertManager.showAlert("Error", error.localizedDescription, self)
                return
            }
            
            // verify that locationInfo is not nil
            guard let locationInfo = locationInfo else {
                print("error getting locationInfo, result is nil")
                AlertManager.showAlert("Error", "Didn't receive data from API", self)
                return
            }
            
            // copy to _passesInfo
            self._locationInfo = locationInfo
            
            // received data - update UI
            self.updateUI(locationInfo)
        }
    }

    // updateUI
    private func updateUI(_ locationInfo : ISSLocationInfo) {
        // call on main thread
        DispatchQueue.main.async {
            // show ISS location
            self.showISSlocation()
        }
    }
    
    // showISSlocation
    private func showISSlocation()
    {
        // Drop a pin at ISS Current Location
        if let loctionInfo = _locationInfo
        {
            let latitude = CLLocationDegrees(loctionInfo.iss_position.latitude);
            let longitude = CLLocationDegrees(loctionInfo.iss_position.longitude);
            
            let bNewAnnotation = (_issAnnotation == nil)
            
            if _issAnnotation == nil {
                _issAnnotation = MKPointAnnotation();
            }
            
            // set coordinate
            _issAnnotation?.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!);
            // re-set title (to forse title redraw when annotation is moving)
            _issAnnotation?.title = "ISS"
            
            if (_issAnnotation != nil) {
                if (bNewAnnotation) {
                    // add annotation
                    self.mapView.addAnnotation(_issAnnotation!)
                
                    // make it in the center
                    self.mapView.setCenter(_issAnnotation!.coordinate, animated: false)
                }
            }
            
        }
    }
    
}

