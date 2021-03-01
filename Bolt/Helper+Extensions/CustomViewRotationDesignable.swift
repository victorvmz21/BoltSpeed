//
//  CustomViewRotationDesignable.swift
//  Bolt
//
//  Created by Victor Monteiro on 2/28/21.
//  Copyright © 2021 Atomuz. All rights reserved.
//

import UIKit

@IBDesignable class CustomLabelRotationDesignable: UILabel {
    
    @IBInspectable var rotate: CGFloat = 0 {
        didSet {
            rotatingView()
        }
    }
    
    func rotatingView() {
        self.transform = CGAffineTransform(rotationAngle: -.pi / rotate)
    }
    
}

@IBDesignable class CustomViewRotationDesignable: UIView {
    
    @IBInspectable var rotate: CGFloat = 0 {
        didSet {
            rotatingView()
        }
    }
    
    func rotatingView() {
        self.transform = CGAffineTransform(rotationAngle: -.pi / rotate)
    }
    
}
