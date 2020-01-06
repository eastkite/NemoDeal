//
//  DealSite.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/23.
//  Copyright © 2019 baedy. All rights reserved.
//

import Foundation

struct DealSite: Codable {
    let id : Int
    let name : String
    
    enum CodingKeys: String, CodingKey{
        case id
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
    }
}
