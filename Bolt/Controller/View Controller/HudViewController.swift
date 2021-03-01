//
//  HudViewController.swift
//  Bolt
//
//  Created by Victor Monteiro on 9/18/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import UIKit
import CoreLocation

class HudViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var metricButton: UIButton!
    @IBOutlet weak var groupingView: UIView!
    
    //MARK: Properties
    let manager = CLLocationManager()
    let speedometer = SpeedometerViewController()
    var speedMultiplier: Double = 0.0
    var isMPH = false
    var navbarIsHidden = false
    var transforming = CGAffineTransform(rotationAngle: -.pi / 2)
    var undoTransforming = CGAffineTransform(rotationAngle: .pi * 2)
    var mirrorLayout = CGAffineTransform(scaleX: -1, y: 1)
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHud()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SpeedTrackController.shared.updateDriverLocation(delegate: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        manager.stopUpdatingLocation()
    }
    
    //MARK: - IBActions
    @IBAction func speedMetricButtonTapped(_ sender: UIButton) {
        isMPH = !isMPH
        UserDefaults.standard.set(isMPH, forKey: "isMPH")
        Haptic.shared.generateHaptic(style: .medium)
        settingSpeedType()
    }
    
    @IBAction func dashCamButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dashVC = storyboard.instantiateViewController(identifier: "dashCam")
        present(dashVC, animated: true, completion: nil)
        
    }
    
    //MARK: - Methods
    func setupHud() {
        self.speedLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.metricButton.transform = CGAffineTransform(scaleX: -1, y: 1)
        settingSpeedType()
        addingGesture()
    }
    
    func addingGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rotatingHud))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func settingSpeedType() {
        let defaultMultiplier = UserDefaults.standard.bool(forKey: "isMPH")
        print(defaultMultiplier)
        speedMultiplier = defaultMultiplier ? 2.2369 : 3.6
        metricButton.setTitle(defaultMultiplier ? "MPH" : "KMH", for: .normal)
    }
    
    @objc func rotatingHud() {
        navbarIsHidden = !navbarIsHidden
        self.navigationController?.isNavigationBarHidden = navbarIsHidden
        self.tabBarController?.tabBar.isHidden = navbarIsHidden
        
        if navbarIsHidden {
            self.groupingView.transform = transforming
            self.speedLabel.transform = mirrorLayout
            self.metricButton.transform = mirrorLayout
        } else {
            self.groupingView.transform = undoTransforming
            self.speedLabel.transform = mirrorLayout
            self.metricButton.transform = mirrorLayout
        }
    }
}

extension HudViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Getting Speed
        guard var speed = locations.last?.speed else { return }
        
        //Converting Speed into MPH or KMP
        speed = speed * speedMultiplier
        
        //Validating Speed
        if speed <= 0  {
            speedLabel.text = "0"
        }  else if speed > 240 {
            speedLabel.text = "240"
        } else if speed > 0.5 {
            speedLabel.text = "\(Int(speed + 1))"
        }
    }
}
