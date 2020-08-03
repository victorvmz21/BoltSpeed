//
//  InterfaceController.swift
//  Bolt WatchKit Extension
//
//  Created by Victor Monteiro on 6/25/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation


class InterfaceController: WKInterfaceController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var speedLabel: WKInterfaceLabel!
    @IBOutlet weak var speedButton: WKInterfaceButton!
    
    //MARK: - Properties
    let manager = CLLocationManager()
    var isMPH = false
    var speedMultiplier: Double = 0.0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        updatingLocation()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    //MARK: - IBAction
    @IBAction func speedTypeButtonTapped() {
       isMPH = !isMPH
        UserDefaults.standard.set(isMPH, forKey: "isMPH")
        settingSpeedType()
    }
    
    //MARK: Methods
    func updatingLocation() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .otherNavigation
        manager.requestWhenInUseAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }
    
    func settingSpeedType() {
        let defaultMultiplier = UserDefaults.standard.bool(forKey: "isMPH")
        speedButton.setTitle(defaultMultiplier ? "MPH" : "KMH")
        speedMultiplier = defaultMultiplier ? 2.2369 : 3.6
    }
}

extension InterfaceController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard var speed = locations.first?.speed else { return }
        
        
        speed *= speedMultiplier
        
        if speed < 0  {
            speedLabel.setText("0")
        }  else if speed > 240 {
            speedLabel.setText("240")
        } else {
            speedLabel.setText("\(Int(speed))")
            print(Int(speed))
        }
    }
}
