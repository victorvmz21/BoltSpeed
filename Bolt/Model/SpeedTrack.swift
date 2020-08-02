//
//  SpeedTracker.swift
//  Bolt
//
//  Created by Victor Monteiro on 7/19/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit

struct speedTrackConstants {
    static let recordTypeKey              = "SpeedTrack"
    static let startLocationNameKey       = "startLocationName"
    static let destinationLocationNameKey = "destinationLocationName"
    static let initialLocationKey         = "initialLocation"
    static let finalLocationKey           = "finalLocation"
    static let averageSpeedKey            = "averageSpeed"
    static let timeTraveledKey            = "timeTraveled"
    static let totalMilesKey              = "totalMiles"
    static let timeStampKey               = "timeStamp"
}

class SpeedTrack {
    
    //MARK: - Properties
    var startLocationName: String
    var destinationLocationName: String
    var initialLocation: CLLocation
    var finalLocation: CLLocation
    var averageSpeed: String
    var timeTraveled: String
    var totlaMiles: String
    var timeStamp: Date
    var recordID: CKRecord.ID
    
    init(startLocationName: String,destinationLocationName: String, initialLocation: CLLocation, finalLocation: CLLocation,
         averageSpeed: String, timeTraveled: String, totalMiles: String, timeStamp: Date = Date(),
         ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.startLocationName       = startLocationName
        self.destinationLocationName = destinationLocationName
        self.initialLocation         = initialLocation
        self.finalLocation           = finalLocation
        self.averageSpeed            = averageSpeed
        self.timeTraveled            = timeTraveled
        self.totlaMiles              = totalMiles
        self.timeStamp               = timeStamp
        self.recordID                = ckRecordId
    }
}

//Trasnforming  CKRecord  into speedTracker to be able show in tableView
extension SpeedTrack {
    convenience init?(ckRecord: CKRecord) {
        
        guard let startLocationName = ckRecord[speedTrackConstants.startLocationNameKey] as? String,
            let destinationLocationName = ckRecord[speedTrackConstants.destinationLocationNameKey] as? String,
            let initialLocation = ckRecord[speedTrackConstants.initialLocationKey] as? CLLocation,
            let finalLocation = ckRecord[speedTrackConstants.finalLocationKey] as? CLLocation,
            let averageSpeed = ckRecord[speedTrackConstants.averageSpeedKey] as? String,
            let timeTraveled = ckRecord[speedTrackConstants.timeTraveledKey] as? String,
            let totalMiles = ckRecord[speedTrackConstants.totalMilesKey] as? String,
            let timeStamp = ckRecord[speedTrackConstants.timeStampKey] as? Date
            else { return nil }
        
        self.init(startLocationName: startLocationName, destinationLocationName: destinationLocationName, initialLocation: initialLocation, finalLocation: finalLocation, averageSpeed: averageSpeed, timeTraveled: timeTraveled, totalMiles: totalMiles, timeStamp: timeStamp, ckRecordId: ckRecord.recordID)
    }
}

//Transforming Speed Tracker to be able to save into CloudKit
extension CKRecord {
    
    convenience init(speedTracker: SpeedTrack) {
        self.init(recordType: speedTrackConstants.recordTypeKey, recordID: speedTracker.recordID)
        self.setValuesForKeys([
            speedTrackConstants.startLocationNameKey: speedTracker.startLocationName,
            speedTrackConstants.destinationLocationNameKey: speedTracker.destinationLocationName,
            
            speedTrackConstants.initialLocationKey: speedTracker.initialLocation,
            speedTrackConstants.finalLocationKey: speedTracker.finalLocation,
            speedTrackConstants.averageSpeedKey: speedTracker.averageSpeed,
            speedTrackConstants.timeTraveledKey: speedTracker.timeTraveled,
            speedTrackConstants.totalMilesKey: speedTracker.totlaMiles,
            speedTrackConstants.timeStampKey: speedTracker.timeStamp
            
        ])
    }
}

extension SpeedTrack: Equatable {
    static func == (lhs: SpeedTrack, rhs: SpeedTrack) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
