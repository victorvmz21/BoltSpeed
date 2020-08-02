//
//  ViewControllerExtension.swift
//  Bolt
//
//  Created by Victor Monteiro on 8/2/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentAlert(alertType: UIAlertController.Style, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertType)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
