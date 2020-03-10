//
//  Deal.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/20.
//  Copyright © 2019 baedy. All rights reserved.
//

import Foundation

struct Deal: Codable {
    // 서버 데이터
    let siteId : Int
    let siteIcon : String
    let id : Int
    let title : String
    let comment : Int
    let category : String
    let recommend : Int
    let decommend : Int
    let url : String
    let end : Bool
    let thumbnail : String?
    let regDate : Date?
    var adUse : Bool
    
    
    // 사용할 데이터
    var dayString : String?
    var timeString : String?
    
    enum CodingKeys: String, CodingKey{
        case siteId
        case siteIcon
        case id = "articleId"
        case title
        case comment
        case category
        case recommend
        case decommend
        case url
        case end = "articleEnd"
        case thumbnail
        case regDate
    }
    
    init() {
        siteId = -1
        siteIcon = ""
        id = -1
        title = ""
        comment = -1
        category = ""
        recommend = -1
        decommend = -1
        url = ""
        end = false
        thumbnail = ""
        regDate = nil
        adUse = true
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        siteId = try values.decode(Int.self, forKey: .siteId)
        siteIcon = try values.decode(String.self, forKey: .siteIcon)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        comment = try values.decode(Int.self, forKey: .comment)
        category = try values.decode(String.self, forKey: .category)
        recommend = try values.decode(Int.self, forKey: .recommend)
        decommend = try values.decode(Int.self, forKey: .decommend)
        url = try values.decode(String.self, forKey: .url)
        end = (try values.decode(Int.self, forKey: .end) == 0 ? false : true)
        thumbnail = try? values.decode(String.self, forKey: .thumbnail)
        let dateString = try values.decode(String.self, forKey: .regDate)
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        formatter.locale = Locale(identifier: "ko_KR")
        regDate = formatter.date(from: dateString)!
        
        adUse = false
    }
}

extension Deal{
    var day : String{
        get{
            let formatter = DateFormatter.init()
            formatter.dateFormat = "M | d"
            formatter.locale = Locale(identifier: "ko_KR")
            
            if let date = self.regDate{
                return formatter.string(from: date)
            }else{
                return ""
            }
        }
    }
    
    var time : String{
        get {
            let formatter = DateFormatter.init()
            formatter.dateFormat = "HH:mm"
            formatter.locale = Locale(identifier: "ko_KR")
            
            if let date = self.regDate{
                return formatter.string(from: date)
            }else{
                return "--:--"
            }
        }
    }
    
    func compareDate(withCompareDeal deal : Deal) -> Bool{
        return self.regDate! > deal.regDate!
    }
    
    func isToday() -> Bool {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        
        if let date = regDate{
            let today = Date()
            let todayString = formatter.string(from: today)
            let selfDayString = formatter.string(from: date)
            if todayString == selfDayString{
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
}
