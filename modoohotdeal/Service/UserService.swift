//
//  UserService.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/30.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit

class UserService: NSObject {
    
    private static var sharedObject : UserService!
    static func shared() -> UserService{
        if sharedObject == nil{
            sharedObject = UserService()
        }
        return sharedObject
    }
    
    var user : UserModel!
    
    func setUser(userData : UserModel){
        self.user = userData
    }
}
