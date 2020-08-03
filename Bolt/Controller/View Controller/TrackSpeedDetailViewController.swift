//
//  TrackSpeedDetailViewController.swift
//  Bolt
//
//  Created by Victor Monteiro on 6/28/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import UIKit
import MapKit

class TrackSpeedDetailViewController: UIViewController {
    //MARK: - IBOutlet
    @IBOutlet weak var startPointLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var speedLimitExceededLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backgrondView: UIView!
    @IBOutlet weak var averageSpeedView: UIView!
    @IBOutlet weak var timeTraveledView: UIView!
    @IBOutlet weak var totalMilesView: UIView!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var totalMilesLabel: UILabel!
    @IBOutlet weak var keyStartPointLabel: UILabel!
    @IBOutlet weak var keyDestinationLabel: UILabel!
    @IBOutlet weak var keyDateLabel: UILabel!
    @IBOutlet weak var keyDistanceLabel: UILabel!
    @IBOutlet weak var keyTimeLabel: UILabel!
    @IBOutlet weak var keyAverageSpeedLabel: UILabel!
    
    //MARK: - Variables
    var speedTrack: SpeedTrack?
    let StartPointTitleKey = NSLocalizedString("Start Point", comment: "")
    let destinationTitleKey = NSLocalizedString("Destination", comment: "")
    let dateTitleKey = NSLocalizedString("Date", comment: "")
    let distanceTitleKey = NSLocalizedString("Distance", comment: "")
    let timeTitleKey = NSLocalizedString("Time", comment: "")
    let averageSpeedTitleKey = NSLocalizedString("Avg Speed", comment: "")
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateViews()
        mapSetup()
    }
    
    //MARK: Methods
    func setupView() {
        mapView.roundViewWith(proportion: 10)
        backgrondView.roundViewWith(proportion: 10)
        averageSpeedView.roundViewWith(proportion: 12)
        timeTraveledView.roundViewWith(proportion: 12)
        totalMilesView.roundViewWith(proportion: 12)
        
        keyStartPointLabel.text = StartPointTitleKey
        keyDestinationLabel.text = destinationTitleKey
        keyDateLabel.text = dateTitleKey
        keyDistanceLabel.text = distanceTitleKey
        keyTimeLabel.text = timeTitleKey
        keyAverageSpeedLabel.text = averageSpeedTitleKey
    }
    
    func updateViews() {
        guard let speedtrack = speedTrack else { return }
        self.speedLimitExceededLabel.text = "\(2) Twice"
        self.timeStampLabel.text = speedtrack.timeStamp.dateAsString()
        self.averageSpeedLabel.text = speedtrack.averageSpeed
        self.totalMilesLabel.text = speedtrack.totlaMiles
        self.totalTimeLabel.text = speedtrack.timeTraveled
        self.title = speedtrack.destinationLocationName
        self.startPointLabel.text = speedtrack.startLocationName
        self.destinationLabel.text = speedtrack.destinationLocationName
    }
    
    //MapView Setup
    func mapSetup() {
        mapView.delegate = self
        mapView.mapType = .hybrid
        showTrackOnMap()
    }

    //Showing track on map and adding polilyne
    func showTrackOnMap() {
        guard let speedTrack = speedTrack else { return }
        let request = SpeedTrackController.shared.createDirectionsRequest(from: speedTrack.initialLocation.coordinate,
                                                                          to: speedTrack.finalLocation.coordinate, mapview: self.mapView)
        let directions = MKDirections(request: request)
        //Calculating Routes
        directions.calculate { (response, error) in
            guard let response  = response else { return }
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
}

extension TrackSpeedDetailViewController: MKMapViewDelegate {
    //Adding Polyline into the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .systemBlue
        return renderer
    }
}
