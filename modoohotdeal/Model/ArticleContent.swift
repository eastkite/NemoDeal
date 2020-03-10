//
//  ArticleContent.swift
//  modoohotdeal
//
//  Created by baedy on 2020/01/17.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

struct ArticleContent: Codable {
    let mainContent : String
    let originLink : String?
    let articleLink : String?
    let imgList : [String]
    let deal : Deal
    
    enum CodingKeys: String, CodingKey{
        case mainContent
        case originLink
        case articleLink
        case imgList
        case deal = "dealData"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mainContent = try values.decode(String.self, forKey: .mainContent)
        originLink = try? values.decode(String.self, forKey: .originLink)
        articleLink = try? values.decode(String.self, forKey: .articleLink)
        let list : [String] = try values.decode([String].self, forKey: .imgList)
        imgList = list.count == 0 ? [] : list
        deal = try values.decode(Deal.self, forKey: .deal)
    }
}
