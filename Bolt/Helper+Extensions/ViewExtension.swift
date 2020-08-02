//
//  ViewExtension.swift
//  Bolt
//
//  Created by Victor Monteiro on 6/25/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundView() {
        self.layer.cornerRadius = self.layer.frame.height / 2
        self.clipsToBounds = true
    }
    
    func roundViewWith(proportion: CGFloat) {
        self.layer.cornerRadius = proportion
        self.clipsToBounds = true
    }
}
