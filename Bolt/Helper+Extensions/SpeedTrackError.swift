//
//  SpeedTrackError.swift
//  Bolt
//
//  Created by Victor Monteiro on 7/19/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import Foundation

enum SpeedTrackError: LocalizedError {
    
    case thrownError(Error)
    case noSpeedTrackFound
    case noRecordFound
    case unableToDeleteRecord
    case couldNotUnwrap
    
    var errorDescription: String? {
        switch self {
        case .thrownError(let error):
            return "\(error.localizedDescription)"
        case .noSpeedTrackFound:
            return "Speed track wasn't found"
        case .noRecordFound:
            return "No record found"
        case .unableToDeleteRecord:
            return "Unable to delete the speed track record from the cloud"
        case .couldNotUnwrap:
            return "Unable to the get the speed track"
        }
    }
}
