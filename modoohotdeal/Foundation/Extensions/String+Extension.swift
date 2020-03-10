//
//  String+Extension.swift
//  modoohotdeal
//
//  Created by baedy on 2020/01/10.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

extension String{

    func topicUTF8() -> String{
        var topic = ""
        if self.utf8.count != 0{
            for c in utf8{
                topic = topic + "%" + String(Int(c), radix: 16, uppercase: true)
            }
        }
        return topic
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
