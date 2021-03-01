//
//  SpeedometerViewController.swift
//  Bolt
//
//  Created by Victor Monteiro on 6/25/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion
import AVFoundation
import NotificationCenter

class SpeedometerViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var speedometerViewOne: UIView!
    @IBOutlet weak var speedometerViewTwo: UIView!
    @IBOutlet weak var speedometerViewThree: UIView!
    @IBOutlet weak var speedometerViewFour: CustomDashedView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var metricButton: UIButton!
    @IBOutlet weak var metricBackground: UIView!
    @IBOutlet weak var metricInsidebackground: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingRedView: UIView!
    @IBOutlet weak var recordingLabel: UILabel!
    
    //MARK: - Variables
    let manager = CLLocationManager()
    var speedMultiplier: Double = 0.0
    var isMPH: Bool = true
    var isRecordingAnimationActive: Bool = false
    var isFinishedRecording: Bool = false
    var totalSpeed: Float = 0.0
    var averageSpeed: String = ""
    var totalTime: String = ""
    var totalMiles: String = ""
    let alertTitle = NSLocalizedString("New Speed Track", comment: "")
    let alertMessage = NSLocalizedString("Speed Track Created Successfully", comment: "")
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SpeedTrackController.shared.updateDriverLocation(delegate: self)
        settingUpViews()
        settingSpeedType()
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.recordingRedView.alpha = 0
        self.recordingLabel.alpha = 0
        recordingAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    //MARK: - IBActions
    @IBAction func speedTypeButtonTapped(_ sender: UIButton) {
        isMPH = !isMPH
        UserDefaults.standard.set(isMPH, forKey: "isMPH")
        Haptic.shared.generateHaptic(style: .medium)
        settingSpeedType()
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        Haptic.shared.generateHaptic(style: .medium)
        isRecordingAnimationActive = !isRecordingAnimationActive
        recordingAnimation()
        isFinishedRecording = isRecordingAnimationActive ? false : true
        SpeedTrackController.shared.updateDriverLocation(delegate: self)
    }
    
    //MARK: Methods
    func settingUpViews() {
        
        speedometerViewOne.roundView()
        speedometerViewTwo.roundView()
        speedometerViewThree.roundView()
        speedometerViewFour.roundView()
        metricBackground.roundView()
        metricInsidebackground.roundView()
        recordButton.roundView()
        recordingRedView.roundView()
        speedometerViewTwo.layer.borderColor = UIColor.systemBlue.cgColor
        speedometerViewTwo.layer.borderWidth = 4
        recordingRedView.isHidden  = true
        recordingLabel.isHidden    = true
        recordingRedView.alpha     = 0
        recordingLabel.alpha       = 0
        self.speedometerViewFour.setNeedsDisplay()
        
    }
    
    func settingSpeedType() {
        let defaultMultiplier = UserDefaults.standard.bool(forKey: "isMPH")
        print(defaultMultiplier)
        speedMultiplier = defaultMultiplier ? 2.2369 : 3.6
        metricButton.setTitle(defaultMultiplier ? "MPH" : "KMH", for: .normal)
    }
    
    ///Recording Animation
    func recordingAnimation() {
        if isRecordingAnimationActive {
            self.recordingRedView.isHidden = false
            self.recordingLabel.isHidden   = false
            
            UIView.animate(withDuration: 0.7) {
                self.recordingLabel.alpha = 1
            }
            
            UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.recordingRedView.alpha = 1
            }, completion: nil)
            
            recordButton.setTitle("Stop", for: .normal)
            
        } else {
            UIView.animate(withDuration: 1.2) {
                self.recordingLabel.alpha = 0
                self.recordingRedView.alpha = 0
            }
            self.recordingRedView.isHidden = true
            self.recordingLabel.isHidden   = true
            recordButton.setTitle("Rec", for: .normal)
        }
    }
    
    @objc func enterForeground() {
        self.recordingRedView.alpha = 0
        self.recordingLabel.alpha = 0
        recordingAnimation()
    }
    
    //    func voiceNotification() {
    //        let synthesizer = AVSpeechSynthesizer()
    //        let utterance = AVSpeechUtterance(string: "Recording Initialized")
    //        synthesizer.speak(utterance)
    //    }
}

//MARK: Extension
extension SpeedometerViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Getting Speed
        guard var speed = locations.first?.speed else { return }
        
        //Converting Speed into MPH or KMP
        speed = speed * speedMultiplier
        
        //Validating Speed
        if speed <= 0  {
            speedLabel.text = "0"
        }  else if speed > 240 {
            speedLabel.text = "240"
        } else {
            speedLabel.text = "\(Int(speed))"
        }
        
        if isFinishedRecording {
            
            //Getting First and last Distance
            guard let firstLocation = SpeedTrackController.shared.locations.first else { return }
            guard let lastLocation  = SpeedTrackController.shared.locations.last  else { return }
            print(lastLocation)
            
            //Getting Destination City Name
            lastLocation.getLocationName { (destinationLocationName) in
                guard let destinationLocationName = destinationLocationName else { print("Last Location is nil")
                    return }
                SpeedTrackController.shared.destinationLocationName = destinationLocationName
                
                //Creating Directions Request to get distance / miles traveled and average speed
                let request = MKDirections.Request()
                guard let firstCoordinate = SpeedTrackController.shared.locations.first?.coordinate else { return }
                guard let lasCoordinate = SpeedTrackController.shared.locations.last?.coordinate else { return }
                let sourcePlaceMark = MKPlacemark(coordinate: firstCoordinate)
                let destinationPlaceMark = MKPlacemark(coordinate:lasCoordinate )
                request.source = MKMapItem(placemark: sourcePlaceMark)
                request.destination = MKMapItem(placemark: destinationPlaceMark)
                
                let directions = MKDirections(request: request)
                
                //Caculating distance, miles and average speed
                directions.calculate { (response, error) in
                    if let error = error {  print(error.localizedDescription) }
                    
                    guard let distance = response?.routes[0].distance else { return }
                    guard let timeTraveled = response?.routes[0].expectedTravelTime else { return }
                    let averageSpeed = Double(distance) / Double(timeTraveled)
                    let minutes = timeTraveled / 60
                    
                    if minutes > 60 {
                        let hours = Int(timeTraveled) / 3600
                        let minutes = Int(timeTraveled) / 60 % 60
                        self.totalTime = String(format: "%02ih%02i", hours, minutes)
                        
                    } else { self.totalTime =  String(format: "%.0f", minutes) + " min" }
                    
                    if UserDefaults.standard.bool(forKey: "isMPH") {
                        self.totalMiles = String(format: "%.1f", distance * 0.00062137) + " mi"
                    } else {
                        self.totalMiles = String(format: "%.1f", distance / 1000.0) + " km"
                    }
                    
                    if self.totalMiles == "0 mi" {
                        self.averageSpeed = "0"
                    } else if self.totalMiles == "0 km" {
                        self.averageSpeed = "0"
                    } else if self.averageSpeed == "nan" {
                        self.averageSpeed = "0"
                    }else {
                        self.averageSpeed = String(format: "%.1f", averageSpeed)
                    }
                    
                    //Creating New Speed Track
                    SpeedTrackController.shared.createSpeedTrackerWith(startLocationName: SpeedTrackController.shared.sourceLocationName, destinationLocationName: SpeedTrackController.shared.destinationLocationName, initialLocation: firstLocation, finalLocation: lastLocation, averageSpeed: self.averageSpeed, timeTraveled: self.totalTime, totalMiles: self.totalMiles ) { (result) in
                        
                        switch result {
                        case .success(let speedTrack):
                            DispatchQueue.main.async {
                                self.presentAlert(alertType: .alert, title: self.alertTitle, message: self.alertMessage)
                            }
                            SpeedTrackController.shared.speedTrackers.insert(speedTrack, at: 0)
                        case .failure(let error):
                            print("Error trying to create a new speed track - \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.presentAlert(alertType: .actionSheet, title: "Error", message: "Couldn't create an Speed track, try again!")
                            }
                        }
                    }
                }
                
                //Reseting Properties
                self.isFinishedRecording = false
                SpeedTrackController.shared.locations.removeAll()
                manager.startUpdatingLocation()
            }
        } else if isRecordingAnimationActive && isFinishedRecording == false {
            //Adding Locations into array
            for location in locations {
                SpeedTrackController.shared.locations.append(location)
                print(SpeedTrackController.shared.locations)
                print(SpeedTrackController.shared.locations.count)
            }
            
            //Getting  initial City Name
            guard let firstLocation = SpeedTrackController.shared.locations.first else { return }
            firstLocation.getLocationName { (startLocationName) in
                guard let startLocationName = startLocationName else { print("Fist location is nil")
                    return  }
                print("Running GetLocationName \(startLocationName)")
                SpeedTrackController.shared.sourceLocationName = startLocationName
            }
        }
        
    }
}
