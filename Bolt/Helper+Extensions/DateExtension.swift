//
//  DateExtension.swift
//  Bolt
//
//  Created by Victor Monteiro on 7/20/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import Foundation

extension Date {
    
    func dateAsString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
