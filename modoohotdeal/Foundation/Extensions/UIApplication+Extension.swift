//
//  UIApplication+Extension.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/30.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /// Window에서 최상위에 있는 viewController 오브젝트입니다.
    var topViewController: UIViewController? {
        var topViewController = keyWindow?.rootViewController
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        
        return (topViewController as? UINavigationController)?.topViewController
    }
    
    var isiPhonexDevice: Bool {
        if #available(iOS 11, *) {
            if (keyWindow?.safeAreaInsets.bottom)! > CGFloat(0.0) {
                return true
            }
        }
        return false
    }
    
}
