//
//  CLLocationExtension.swift
//  Bolt
//
//  Created by Victor Monteiro on 7/27/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    
    func getLocationName(completion: @escaping (String?) -> Void) {
        CLGeocoder().reverseGeocodeLocation(self) { (placemarks, error) in
            if let error = error {
                print("Error reversing locations - \(error.localizedDescription)")
                return completion(nil)
            }
            
            guard let locationCityName = placemarks?.first?.locality, !locationCityName.isEmpty else { return completion(nil) }
            guard let stateName = placemarks?.first?.administrativeArea, !stateName.isEmpty else { return completion(nil) }
            
            let fullLocation = "\(locationCityName) - \(stateName)"
            print(fullLocation)
            completion(fullLocation)
        }
    }
}
