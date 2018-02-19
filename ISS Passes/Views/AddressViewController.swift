//
//  AddressViewController.swift
//  ISS Passes
//
//  Created by Maxim on 2/18/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit
import CoreLocation

// AddressViewControllerDelegate
protocol AddressViewControllerDelegate {
    func notifyCoordinatesSourceChanged()
}

// AddressViewController
class AddressViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var textAddress: UITextField!
    @IBOutlet weak var buttonFind: UIButton!
    @IBOutlet weak var labelGeoStatus: UILabel!
    @IBOutlet weak var buttonDone: UIButton!
    
    var delegate: AddressViewControllerDelegate?
    var _addressLocation : CLLocation?
    
    // viewDidLoad
    override func viewDidLoad() {
        // super
        super.viewDidLoad()

        // set data
        setData()
        
        // enable / disable
        enableControls()
    }

    // didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // Action handlers
    //
    
    @IBAction func segControlSelectionChanged(_ sender: Any) {
        // enable / disable
        enableControls()
    }
    
    @IBAction func textAddressValueChanged(_ sender: Any) {
        // enable / disable
        enableControls()
    }
    
    @IBAction func buttonFindPressed(_ sender: Any) {
        // geocode address
        findAddressCoordinates()
    }
    
    @IBAction func onCancel(_ sender: Any) {
        // dismiss
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onDone(_ sender: Any) {
        // get data
        getData()
        
        // dismiss
        dismiss(animated: true, completion: nil)
    }
    
    //
    // Private functions
    //
    
    // setData
    private func setData()
    {
        // get AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // segControl
        segControl.selectedSegmentIndex = (appDelegate.configManager?.coordinatesSource == .device) ? 0 : 1
        
    }
    
    // enableControls
    private func enableControls()
    {
        let useDevice = (segControl.selectedSegmentIndex == 0)
        
        labelAddress.isEnabled = !useDevice
        textAddress.isEnabled = !useDevice
        buttonFind.isEnabled = !useDevice
        
        if !useDevice {
            if (textAddress.text != nil) {
                buttonFind.isEnabled = (textAddress.text!.count > 0)
            }
            
            buttonDone.isEnabled = (self._addressLocation != nil)
        }
        else {
            buttonDone.isEnabled = true
        }
        
        labelGeoStatus.isHidden = (useDevice || self._addressLocation == nil)
    }
    
    // findAddressCoordinates
    private func findAddressCoordinates()
    {
        // get AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // geocode address
        appDelegate.geoLocationService?.findCoordinatesByAddress(textAddress.text!){ (addressLocation, error) in
            if error != nil {
                // error
                self._addressLocation = nil
            }
            else {
                // copy to _addressLocation
                self._addressLocation = addressLocation
            }
            
            // show geocoding status - on main thread
            DispatchQueue.main.async {
                self.showGeocodingStatus()
                self.enableControls()
            }
        }
    }
    
    // showGeocodingStatus
    private func showGeocodingStatus()
    {
        let useDevice = (segControl.selectedSegmentIndex == 0)
        
        if (useDevice) {
            labelGeoStatus.isHidden = true
            labelGeoStatus.text = ""
        }
        else {
            labelGeoStatus.isHidden = false
            
            if (_addressLocation != nil) {
                let found = (_addressLocation?.coordinate.latitude != 0 && _addressLocation?.coordinate.longitude != 0)
                labelGeoStatus.text = found ? "Address Found" : "Address Not Found"
            }
            else {
                labelGeoStatus.text = "Address Not Found"
            }
        }
        
    }
    
    // getData
    private func getData()
    {
        // get AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
     
        let useDevice = (segControl.selectedSegmentIndex == 0)
        
        // check if data was changed
        if (appDelegate.configManager?.coordinatesSource == .device && useDevice) {
            return
        }
        
        // change configuration
        appDelegate.configManager?.coordinatesSource = (useDevice) ? .device : .address
        
        if (useDevice) {
            // start using device coordinates
            appDelegate.geoLocationService?.startUpdatingLocation()
        }
        else {
            // start using address coordinates
            appDelegate.geoLocationService?.stopUpdatingLocation()
            // copy location
            appDelegate.geoLocationService?.lastLocation = self._addressLocation
            
            // notify deligate
            if let delegate = self.delegate {
                delegate.notifyCoordinatesSourceChanged()
            }
        }
        
    }
    
}
