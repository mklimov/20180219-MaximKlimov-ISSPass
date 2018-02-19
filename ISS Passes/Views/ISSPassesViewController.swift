//
//  ISSPassesViewController.swift
//  ISS Passes
//
//  Created by Maxim Klimov on 2/17/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit

class ISSPassesViewController: UIViewController, UITableViewDataSource, UIPopoverPresentationControllerDelegate,
                                GeoLocationServiceDelegate, AddressViewControllerDelegate {
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelAddress: UILabel!
    
    // variable for retrieved ISS Passes info
    var _passesInfo : ISSPassInfo?
    
    // BONUS: view controller to select address
    var _addressViewController : AddressViewController?
    
    // viewDidLoad
    override func viewDidLoad() {
        // super
        super.viewDidLoad()
        
        // set tableView.dataSource
        self.tableView.dataSource = self
        
        // BONUS
        // make labelAddress "clickable" to search by address
        let tap = UITapGestureRecognizer(target: self, action: #selector(searchByAddress))
        labelAddress.isUserInteractionEnabled = true
        labelAddress.addGestureRecognizer(tap)
       
    }

    // viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        // super
        super.viewWillAppear(animated)
        
        // set geoLocationService delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.geoLocationService?.delegate = self
        
    }
    
    // viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        // super
        super.viewDidAppear(animated)
        
        // get appDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // verify that Lacation Services are enabled
        if (appDelegate.geoLocationService?.isLocationServiceEnabled() == false) {
            AlertManager.showAlert("Error", "Required Location Services are disabled.\nPlease enable them in Settings.", self)
        } else
        // verify that Location access isn't denied by user
        if (appDelegate.geoLocationService?.isLocationAccessDenied())! {
            AlertManager.showAlert("Error", "Required Location Acess is denied for this app.\nPlease enable it in Settings.", self)
        }
    }
    
    // didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //
    // UITableViewDataSource methods
    //

    // numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        // table wil have just 1 section
        return 1
    }
    
    // numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = _passesInfo?.response.count {
            return count
        }
        else {
            return 0
        }
    }

    // cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let reusableIdentifier = "ISSPassesViewTableCell"
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier) else {
                return UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: reusableIdentifier)
            }
            return cell
         }()
        
        if let passInfo = _passesInfo {
            let rowIndex = indexPath.row
            
            // prepare text
            let riseText = passInfo.getRiseTimeText(index: rowIndex)
            let durationText = passInfo.getDurationText(index: rowIndex)
        
            // set cell
            cell.textLabel?.text = "\(riseText)"
            cell.detailTextLabel?.text = "duration: \(durationText)"
            
            // alternate cell backgroundColor
            if ((rowIndex % 2) == 0) {
                cell.backgroundColor = UIColor.white
            }
            else {
                // #D0E0EB
                cell.backgroundColor = UIColor(red: 208 / 255.00, green: 224.0 / 255.00, blue: 235.0 / 255.00, alpha: 1)
            }

        }
        
        return cell
    }
    
    //
    // GeoLocationServiceDelegate functions
    //
    
    // notifyLocationUpdated
    func notifyLocationUpdated() {
        // update data and UI
        updateData()
    }
    
    // notifyLocationUpdateDidFailWithError
    func notifyLocationUpdateDidFailWithError(_ error: Error) {
        // TBD
    }
    
    // notifyLocationAddress
    func notifyLocationAddress(_ shortAddress: String) {
        // call on main thread
        DispatchQueue.main.async {
            // show address
            self.labelAddress.text = shortAddress
        }
    }
    
    //
    // Private functions
    //
    
    // updateData
    private func updateData() {
        
        // get AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // verify that device location was already found
        guard let location = appDelegate.geoLocationService?.lastLocation else {
            // location is not determined yet
            return
        }

        // populate API parameters
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        let altitude = location.altitude != 0.0 ? String(location.altitude) : ""    // altitude can't be "0.0"
        
        let passes = (appDelegate.configManager?.passes)!
        
        // call OpenNotifyAPI
        OpenNotifyAPIManager.retrieveISSPasses(latitude, longitude, altitude, String(passes)){ (passesInfo, error) in
            // check for error
            if let error = error {
                AlertManager.showAlert("Error", error.localizedDescription, self)
                return
            }
            
            // verify that passesInfo is not nil
            guard let passesInfo = passesInfo else {
                AlertManager.showAlert("Error", "Didn't receive data from API", self)
                return
            }
            
            // copy to _passesInfo
            self._passesInfo = passesInfo
            
            // received data - update UI
            self.updateUI(passesInfo)
        }
        
        // BONUS
        appDelegate.geoLocationService?.findAddressByCoordinates(latitude, longitude)
        
    }
    
    // updateUI
    private func updateUI(_ passesInfo : ISSPassInfo) {
        // call on main thread
        DispatchQueue.main.async {
            // reload data in tableView
            self.tableView.reloadData()
            
            // scroll to top
            let indexPath = NSIndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    // searchByAddress
    @objc private func searchByAddress() {
        if (_addressViewController == nil) {
            _addressViewController = storyboard?.instantiateViewController(withIdentifier: "Address_View_Controller") as? AddressViewController
            
            _addressViewController?.modalPresentationStyle = .popover
            _addressViewController?.delegate = self
        }
        
        let popoverVC = _addressViewController?.popoverPresentationController
        popoverVC?.delegate = self
        popoverVC?.sourceView = self.labelAddress
        popoverVC?.sourceRect = CGRect(x: self.labelAddress.bounds.midX, y: self.labelAddress.bounds.maxY, width: 0, height: 0)
        _addressViewController?.preferredContentSize = CGSize(width: 320, height: 220)
        
        // show popover
        if (_addressViewController != nil) {
            self.present(_addressViewController!, animated: true)
        }

    }
    
    //
    // UIPopoverPresentationControllerDelegate
    //
    
    // adaptivePresentationStyle
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // make to look as Popover on iPhone
        return .none
    }
    
    // notifyCoordinatesSourceChanged
    func notifyCoordinatesSourceChanged() {
        // call on main thread
        DispatchQueue.main.async {
            // show address
            self.updateData()
        }
    }
    
    
}

