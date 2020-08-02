//
//  Haptic.swift
//  Bolt
//
//  Created by Victor Monteiro on 7/19/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import UIKit

class Haptic {
    
    //shared instance
    static let shared = Haptic()
    
    func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let hapticGenerator = UIImpactFeedbackGenerator(style: style)
        hapticGenerator.impactOccurred()
    }
}
