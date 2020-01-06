//
//  loadingService.swift
//  modoohotdeal
//
//  Created by baedy on 2020/01/02.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

class LoadingIndicatorPresenter {
    
    static let `default` = LoadingIndicatorPresenter()
    private var retainCount = 0
    var container: UIView = UIView()
    var indicator = UIActivityIndicatorView()
    
    func startLoading(isUserInteractionEnabled: Bool? = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.retainCount = self.retainCount + 1
            
            self.container.isUserInteractionEnabled = isUserInteractionEnabled!
            
            
            self.indicator.style = .whiteLarge
            self.indicator.color = #colorLiteral(red: 0.2034193065, green: 0.3516695205, blue: 0.9123501712, alpha: 1)
            self.indicator.frame = CGRect(x:0, y:0, width:60, height:60)
            self.indicator.alpha = 1
            self.indicator.center = CGPoint(x: self.container.frame.size.width / 2, y: self.container.frame.size.height / 2)
            
            self.container.addSubview(self.indicator)
            self.indicator.startAnimating()
            if let window = UIApplication.shared.keyWindow {
                self.indicator.center = window.center
                self.container.frame = window.frame
                self.container.center = window.center
                window.addSubview(self.container)
            }
        }
    }
    
    func stopLoading(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.retainCount = max(0, self.retainCount - 1)
            if self.retainCount != 0 {
                return
            }
            self.indicator.stopAnimating()
            self.container.removeFromSuperview()
            completion?()
        }
    }
    
}

