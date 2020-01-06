//
//  User.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/30.
//  Copyright © 2019 baedy. All rights reserved.
//

import Foundation

struct UserModel: Codable {
    let seq : Int
    let comment : Int
    let recommend : Int
    
    enum CodingKeys: String, CodingKey{
        case seq
        case comment
        case recommend
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        seq = try values.decode(Int.self, forKey: .seq)
        comment = try values.decode(Int.self, forKey: .comment)
        recommend = try values.decode(Int.self, forKey: .recommend)
    }
}
