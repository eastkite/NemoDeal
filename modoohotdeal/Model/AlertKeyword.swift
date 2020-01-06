//
//  AlertKeyword.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/30.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit

struct AlertKeyword: Codable {
    let keyword : String
    let alert : Bool    
    
    enum CodingKeys: String, CodingKey{
        case keyword
        case alert
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        keyword = try values.decode(String.self, forKey: .keyword)
        alert = try values.decode(Int.self, forKey: .alert) == 0 ? false : true
    }
}
