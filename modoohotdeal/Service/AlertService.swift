//
//  AlertService.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/30.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit

class AlertService: NSObject {
    
    private static var sharedObject : AlertService!
    static func shared() -> AlertService{
        if sharedObject == nil{
            sharedObject = AlertService()
        }
        return sharedObject
    }
    
    var vc : UIAlertController!
    
    override init(){
        vc = UIAlertController()
    }
    
    func alertInit(title: String, message : String, preferredStyle: UIAlertController.Style) -> AlertService{
        vc = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        return self
    }
    
    func addTextField(configure: ((UITextField) -> Void)? = nil) -> AlertService{
        vc.addTextField(configurationHandler: configure)
        return self
    }
    
    func addAction(title : String, style: UIAlertAction.Style, handler : ((UIAlertAction) -> Void)? = nil) -> AlertService{
        let action = UIAlertAction(title: title, style: style, handler: handler)
        vc.addAction(action)
        return self
    }
    
    func showAlert(){
        UIApplication.shared.topViewController?.present(vc, animated: true, completion: nil)
    }    
}
