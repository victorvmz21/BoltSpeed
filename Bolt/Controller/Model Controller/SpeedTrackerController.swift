//
//  SpeedTrackerController.swift
//  Bolt
//
//  Created by Victor Monteiro on 7/19/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit

class SpeedTrackController {
    
    //MARK: - Shared Instance
    static let shared = SpeedTrackController()
    
    //MARK: - S.O.T
    var speedTrackers: [SpeedTrack] = []
    
    //MARK: - Private Data base
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //MARK: - Properties
    var locationManager = CLLocationManager()
    
    //MARK: - Methods
    
    ///Crud Methods
    ///Create
    func createSpeedTrackerWith(averageSpeed: Double, initialLocation: CLLocation,finalLocation: CLLocation, hoursTraveled: String, completion: @escaping (Result<SpeedTrack, SpeedTrackerError>) -> Void) {
        let newSpeedTrack = SpeedTrack(averageSpeed: averageSpeed, initialLocation: initialLocation,
                                       finalLocation: finalLocation, hoursTraveled: hoursTraveled)
        
       let speedTrackRecord = CKRecord(speedTracker: newSpeedTrack)
        
        privateDB.save(speedTrackRecord) { (record, error) in
            if let error = error {
                print("There was an error saving the hype")
                return completion(.failure(.thrownError(error)))
            }
            
            guard let record = record, let savedSpeedTrack = SpeedTrack(ckRecord: record) else {
                return completion(.failure(.couldNotUnwrap))
            }
            
            print("Saved Speed Track Succesfully")
            completion(.success(savedSpeedTrack))
        }
    }
    
    ///Delete
    func delete(speedTrack: SpeedTrack, completion: @escaping (Result<Bool, SpeedTrackerError>) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [speedTrack.recordID])
        
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (_, recordIDs, error) in
            if let error = error {
                print("there was an error deleting the Speed Track record \(error.localizedDescription)")
                return completion(.failure(.thrownError(error)))
            }
            
            guard let recordIDs = recordIDs else { return completion(.failure(.couldNotUnwrap)) }
            
            if recordIDs.count > 0 {
                print("Record Deleted Successfully")
                completion(.success(true))
            } else { return completion(.failure(.unableToDeleteRecord)) }
        }
        
        privateDB.add(operation)
    }
    
    func fetchSpeedTracks(completion: @escaping (Result<[SpeedTrack]?, SpeedTrackerError>) -> Void) {
        let predicate = NSPredicate(value: true)
        let ckQuery = CKQuery(recordType: speedTrackConstants.recordTypeKey, predicate: predicate)
        privateDB.perform(ckQuery, inZoneWith: nil) { (records, error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            }
            
            guard let records = records else { return completion(.failure(.noRecordFound)) }
            let speedTracks = records.compactMap{ SpeedTrack(ckRecord: $0)}
            self.speedTrackers = speedTracks
            completion(.success(speedTracks))
        }
    }
    
    func gettinCurrentPosition(delegate: CLLocationManagerDelegate) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = delegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    ///My House
    //40.310780, -111.699131
}
