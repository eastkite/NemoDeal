//
//  HotdealProvider.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/20.
//  Copyright © 2019 baedy. All rights reserved.
//

import Moya

enum HotdealProvider {
    case hotdeal(dbTableIndex: Int, id: Int?)
    case dealList
    case deleteArticle(dbId: Int, id: Int)
    case user(token: String)
    case getKeyword
    case registKeyword(keyword: String)
    case updateKeywordAlert(keyword: String, alert: Bool)
    case deleteKeyword(keyword: String)
    case getMainContents(dbId: Int, articleId: Int)
    case getSearchKeyword(keyword: String)
}

extension HotdealProvider : TargetType{
    var baseURL: URL {
        switch self {
        case .hotdeal, .dealList, .getMainContents, .deleteArticle, .getSearchKeyword:
            return URL(string: Configuration.current.serviceApiServer + "/")!
        case .user, .getKeyword, .updateKeywordAlert, .registKeyword, .deleteKeyword:
            return URL(string: Configuration.current.serviceApiServer + "/user/")!
        }
    }
    
    var path: String {
        switch self {
        case .hotdeal:
            return "hotdeal"
        case .dealList:
            return "hotdeal/list"
        case .deleteArticle:
            return "hotdeal/article"
        case .user:
            return "registId"
        case .getKeyword, .registKeyword, .updateKeywordAlert, .deleteKeyword:
            return "keyword"
        case .getMainContents:
            return "hotdeal/mainContent"
        case .getSearchKeyword:
            return "hotdeal/search"
        }
    }
    
    var method: Method {
        switch self {
        case .hotdeal, .dealList, .getKeyword, .getMainContents, .getSearchKeyword:
            return .get
        case .registKeyword, .user:
            return .post
        case .updateKeywordAlert:
            return .put
        case .deleteKeyword, .deleteArticle:
            return .delete
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        var param : [String : Any] = [:]
        switch self {
        case let .hotdeal(value):
            param["dbTableIndex"] = value.dbTableIndex
            if let id = value.id{
                param["id"] = id
            }
            param["count"] = 40
            param["containEnd"] = UserDefaults.standard.string(forKey: UserDefaultsKey.containEnd.rawValue)
        case let .user(value):
            param["fcmToken"] = value
            param["deviceId"] = UUIDService.default.uuid
            
        case let .registKeyword(value):
            param["keyword"] = value
            param["userSeq"] = UserService.shared().user.seq
            
        case let .updateKeywordAlert(value):
            param["keyword"] = value.keyword
            param["alert"] = value.alert ? 1 : 0
            param["userSeq"] = UserService.shared().user.seq
            
        case .getKeyword:
            param["userSeq"] = UserService.shared().user.seq
        
        case let .deleteKeyword(value):
            param["userSeq"] = UserService.shared().user.seq
            param["keyword"] = value
        case let .getMainContents(value):
            param["dbId"] = value.dbId
            param["articleId"] = value.articleId
        case let .deleteArticle(value):
            param["dbId"] = value.dbId
            param["articleId"] = value.id
        case let .getSearchKeyword(value):
            param["key"] = value
            param["containEnd"] = UserDefaults.standard.string(forKey: UserDefaultsKey.containEnd.rawValue)
        default: return .requestPlain
        }
        return .requestParameters(parameters: param, encoding: parameterEncodingForMethod())
    }
    
    func parameterEncodingForMethod() -> ParameterEncoding{
        return self.method == .get ? URLEncoding.default : JSONEncoding.default
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    var errors: Set<HotdealProvider.ResultCode>? {
        switch self {
        case .hotdeal:
            return [.hd_4001, .hd_4041]
        case .registKeyword:
            return [.hd_4042]
        case .getMainContents:
            return [.hd_4045]
        case .getSearchKeyword:
            return [.hd_4045]
        default:
            return nil
        }
    }
}

extension HotdealProvider{
    
    enum Error: Swift.Error {
        case serverMaintenance(message: String)
        // 비정상 응답 (오류코드)
        case failureResponse(api: HotdealProvider, code: HotdealProvider.ResultCode)
        // 잘못된 응답 데이터 (발생시 서버 문의)
        case invalidResponseData(api: HotdealProvider)
    }
    
    enum ResultCode: String {
        case hd_0000 = "0000" // 정의되지 않은 오류
        
        // HTTP 상태코드 200
        case hd_2000 = "2000" // 요청 성공
        
        // HTTP 상태코드 400
        case hd_4001 = "4001" // db 데이터 비정상
        case hd_4041 = "4041" // 테이블 지정 안하였을 경우
        case hd_4042 = "4042" // 데이터 중복
        
        case hd_4045 = "4045" // 데이터 없음 (본문 내용 없음)
        
        var code: String {
            if let index = rawValue.index(of: "_") {
                return String(rawValue[rawValue.index(after: index)...])
            }
            return rawValue
        }
    }
}
