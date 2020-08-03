//
//  SpeedTrackController.swift
//  Bolt
//
//  Created by Victor Monteiro on 7/19/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import Foundation
import MapKit
import CloudKit

class SpeedTrackController {
    
    //MARK: - Shared Instance
    static let shared = SpeedTrackController()
    
    //MARK: - S.O.T
    var speedTrackers: [SpeedTrack] = []
    var locations: [CLLocation] = []
    var speed: [CLLocationSpeed] = []
    var sourceLocationName = ""
    var destinationLocationName = ""
    
    //MARK: - Private Data base
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //MARK: - Properties
    var locationManager = CLLocationManager()
    var geoCoder = CLGeocoder()
    
    //MARK: Crud Methods
    //Create
    func createSpeedTrackerWith(startLocationName: String, destinationLocationName: String, initialLocation: CLLocation,finalLocation: CLLocation, averageSpeed: String,timeTraveled : String,  totalMiles: String, completion: @escaping (Result<SpeedTrack, SpeedTrackError>) -> Void) {
        
        let newSpeedTrack = SpeedTrack(startLocationName: startLocationName, destinationLocationName: destinationLocationName, initialLocation: initialLocation, finalLocation: finalLocation, averageSpeed: averageSpeed, timeTraveled: timeTraveled, totalMiles: totalMiles)
        
        //Speed Record
        let speedTrackRecord = CKRecord(speedTracker: newSpeedTrack)
        
        //Saving Record to Cloud
        privateDB.save(speedTrackRecord) { (record, error) in
            if let error = error { return completion(.failure(.thrownError(error))) }
            
            guard let record = record, let savedSpeedTrack = SpeedTrack(ckRecord: record) else {
                return completion(.failure(.couldNotUnwrap))
            }
            completion(.success(savedSpeedTrack))
        }
    }
    
    //Delete Method
    func delete(speedTrack: SpeedTrack, completion: @escaping (Result<Bool, SpeedTrackError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [speedTrack.recordID])
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsCompletionBlock = { (_, recordIDs, error) in
            if let error = error { return completion(.failure(.thrownError(error))) }
            guard let recordIDs = recordIDs else { return completion(.failure(.couldNotUnwrap)) }
            
            if recordIDs.count > 0 {
                guard let index = self.speedTrackers.firstIndex(of: speedTrack) else { return }
                self.speedTrackers.remove(at: index)
                
                completion(.success(true))
            } else { return completion(.failure(.unableToDeleteRecord)) }
        }
        privateDB.add(operation)
    }
    
    //Fetch Speed Track
    func fetchSpeedTracks(completion: @escaping (Result<[SpeedTrack], SpeedTrackError>) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let ckQuery = CKQuery(recordType: speedTrackConstants.recordTypeKey, predicate: predicate)
        
        //Fetching Data from Cloud
        privateDB.perform(ckQuery, inZoneWith: nil) { (records, error) in
            if let error = error { return completion(.failure(.thrownError(error)))  }
            guard let records = records else { return completion(.failure(.noRecordFound)) }
            let speedTracks = records.compactMap{ SpeedTrack(ckRecord: $0)}
            self.speedTrackers = speedTracks
            
            completion(.success(speedTracks))
        }
    }
    
    //Updating Drivers Location
    func updateDriverLocation(delegate: CLLocationManagerDelegate) {
        locationManager.delegate = delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .otherNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
    
    //Directions Request
    ///This function creates a Direction Request and all add pints into the map
    func createDirectionsRequest(from startPointCoordinate: CLLocationCoordinate2D, to destinationPointCoordinate: CLLocationCoordinate2D, mapview: MKMapView) -> MKDirections.Request {
        
        ///PlaceMark
        let startPoint = MKPlacemark(coordinate: startPointCoordinate)
        let destinationPoint = MKPlacemark(coordinate: destinationPointCoordinate)
        
        ///Adding Pin to Maps
        let sourceAnnotation = MKPointAnnotation()
        let destinationAnnotation = MKPointAnnotation()
        
        //Setting Up Coordinate to Pins to show in the right location
        sourceAnnotation.coordinate = startPointCoordinate
        destinationAnnotation.coordinate = destinationPointCoordinate
        
        //Adding Title to Pins Annotation
        sourceAnnotation.title = "Start Point"
        sourceAnnotation.subtitle = "Lat: \(startPointCoordinate.latitude) Long: \(startPointCoordinate.longitude)"
        destinationAnnotation.title = "Destination"
        destinationAnnotation.subtitle = "Lat: \(destinationPointCoordinate.latitude) Long: \(destinationPointCoordinate.longitude)"
        
        //Adding pins into map
        mapview.addAnnotations([sourceAnnotation, destinationAnnotation])
        
        //Setting up Request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark:  startPoint)
        request.destination = MKMapItem(placemark: destinationPoint)
        request.transportType = .automobile
        
        return request
    }
    
}

