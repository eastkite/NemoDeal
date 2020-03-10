//
//  UIViewController+Extension.swift
//  modoohotdeal
//
//  Created by baedy on 2020/01/09.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

extension UIViewController: UIGestureRecognizerDelegate{
    
    
    private func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
}
