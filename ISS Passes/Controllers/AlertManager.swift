//
//  AlertManager.swift
//  ISS Passes
//
//  Created by Maxim on 2/18/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit

// AlertManager
struct AlertManager {
    
    // showAlert
    static func showAlert(_ title: String, _ message : String, _ viewController: UIViewController) {
        // create alert
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // add action
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // show alert
        viewController.present(alertController, animated: true, completion: nil)
    }
}
