//
//  NetworkService.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/20.
//  Copyright © 2019 baedy. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa

struct NetworkService {
    #if RELEASE
    static let provider = MoyaProvider<HotdealProvider>(plugins: [])
    #else
    static let provider = MoyaProvider<HotdealProvider>(plugins:[NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])
    
    #endif
    static let encoder = JSONEncoder()
}

extension NetworkService{
    struct Hotdeal {
        /// 현재 서비스 하고 있는 핫딜 사이트 리스트를 내려 받는다
        static func getSiteList() -> Observable<[DealSite]>{
            return request(.dealList)
        }
        
        /// 서비스 중인 사이트의 id 및 제일 밑의 article id를 입력한다.
        /// id가 없으면 최신의 20개를 내려주며
        /// id가 있으면 그 id보다 낮은 id의 article 20개를 내려준다
        static func getHotDeal(site: Int, id: Int? = nil) -> Observable<[Deal]>{
            return request(.hotdeal(dbTableIndex: site, id: id))
        }
        
        static func getContents(site: Int, articleId: Int) -> Observable<ArticleContent>{
            return request(.getMainContents(dbId: site, articleId: articleId))
        }
        
        static func deleteArticle(site: Int, articleId: Int) -> Observable<EmptyModel>{
            return request(.deleteArticle(dbId: site, id: articleId))
        }
        
        static func getSearch(withKeyword keyword:String) -> Observable<[Deal]>{
            return request(.getSearchKeyword(keyword: keyword))
        }
    }
    
    struct User{
        static func postUser(token: String) -> Observable<UserModel>{
            return request(.user(token: token))
        }
    }
    
    struct Keyword{
        static func getKeyword() -> Observable<[AlertKeyword]> {
            return request(.getKeyword)
        }
        
        static func registKeyword(keyword: String) -> Observable<EmptyModel> {
            return request(.registKeyword(keyword: keyword))
        }
        
        static func updateAlert(keyword: String, alert: Bool) -> Observable<EmptyModel>{
            return request(.updateKeywordAlert(keyword: keyword, alert: alert))
        }
        
        static func deleteKeyword(keyword: String) -> Observable<EmptyModel>{
            return request(.deleteKeyword(keyword: keyword))
        }
    }
}

extension NetworkService{
    static func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data // fallback to original data if it can't be serialized.
        }
    }
}

extension NetworkService{
    private static func request<T: Decodable>(_ api: HotdealProvider, silent: Bool = false) -> Observable<T> {
        
        let request = Observable<T>.create { observer in
            if !silent {
                LoadingIndicatorPresenter.default.startLoading()
            }
            
            let o = NetworkService.provider.rx
                .request(api)
                .subscribe{ event in
                    switch event {
                    case .success(let response):
                        do {
                            
//                            Log.d("network response : \(String(describing:response.response))")
                            
                            //                            do {
                            //                                let jsonData = try encoder.
                            //                                encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
                            //                                if let jsonString = String(data: jsonData, encoding: .utf8){
                            //                                    Log.d("response json : \(jsonString)")
                            //                                }
                            //                            }catch let error{
                            //                                Log.d("response data is nil : \(error)")
                            //                            }
                            
                            let code = try response.map(String.self, atKeyPath: "code")
                            let resultCode = HotdealProvider.ResultCode(rawValue: code.lowercased()) ?? .hd_0000
                            
                            if resultCode == .hd_2000 {
                                let data = try response.map(T.self, atKeyPath: "result")
//                                Log.d("resposeData \(data)")
                                observer.on(.next(data))
                                observer.on(.completed)
                            } else {
//                                Log.e("network error code : \(resultCode.rawValue)")
                                observer.on(.error(HotdealProvider.Error.failureResponse(api: api, code: resultCode)))
                            }
                        } catch let error {
//                            Log.e("network error :\(error.localizedDescription)")
                            observer.on(.error(error))
                        }
                    case .error(let error):
//                        Log.e("network error response :\(error.localizedDescription)")
                        observer.on(.error(error))
                    }
                    if !silent {
                        LoadingIndicatorPresenter.default.stopLoading()
                    }
            }
            
            return Disposables.create{
                o.dispose()
            }
            }.observeOn(MainScheduler.instance)
        
        return silent ? request : request.retryWhen{ $0.flatMap { _retry(api: api, error: $0)}}
    }
    
    private static func _retry(api: HotdealProvider, error: Error) -> Observable<()> {
        return Observable.create { observer in
            var resultCode: HotdealProvider.ResultCode = .hd_0000
            if let apiServerError = error as? HotdealProvider.Error, case .failureResponse(let api, let code) = apiServerError {
                if let errors = api.errors, errors.contains(code) {
                    observer.on(.error(error))
                    return Disposables.create()
                }
                resultCode = code
            }
            
//            if resultCode == .ar_30000004 {
//                AuthKey.current.login(forSession: {
//                    observer.on(.next(()))
//                    observer.on(.completed)
//                })
//            }
            
            if resultCode == .hd_0000 {
//                if api.method == .get, api.baseURL == HotdealProvider.userGet.baseURL {
                    // TODO : 3번 retry -> 4번째 앱 종료
//                    loginErrorCount += 1
//
//                    DispatchQueue.main.async {
//                        let dialog = CustomUIAlertController(title: R.String.guide, message: loginErrorCount == 4 ? R.String.Login.exit_alert : R.String.Login.retryLogin_alert
//                            , preferredStyle: .alert)
//                        let confirmAction = UIAlertAction(title: R.String.confirm, style: .default, handler : { _ in
//                            if loginErrorCount == 4  { // 3번 이상 시도 후에는 종료 팝업 노출
//                                observer.on(.completed)
//                                exit(0)
//                            } else { // 3번까지는 재시도 팝업 노출
//                                observer.on(.next(()))
//                                observer.on(.completed)
//                            }
//                        })
//                        confirmAction.setValue(#colorLiteral(red: 0.3882352941, green: 0.6705882353, blue: 0.4274509804, alpha: 1), forKey: "titleTextColor")
//                        dialog.addAction(confirmAction)
//                        AlertService.default.setDialog(dialog: dialog)
//                    }
//                }else {
//                    DispatchQueue.main.async {
////                        DeviceManager.default.networkErrorNoti()
//                    }
//                }
//                //                else{
                //                    DispatchQueue.main.async {
                //                        Log.e("message : \(error.localizedDescription)")
                //                        Toast.show(title: R.String.notice, message: message, duration: 2.0)
                //                    }
                //                }
            }
            return Disposables.create()
        }
    }
}

extension ObservableType {
    @discardableResult
    func on() -> Disposable {
        return on(next: { _ in }, error: nil)
    }
    
    @discardableResult
    func on(next: @escaping (Self.E) -> Void) -> Disposable {
        return on(next: next, error: nil)
    }
    
    @discardableResult
    func on(next: @escaping (Self.E) -> Void, error errorHandler: ((HotdealProvider.ResultCode) -> Void)? = nil) -> Disposable {
        return subscribe(
            onNext: next,
            onError: { error in
                if let apiServerError = error as? HotdealProvider.Error, case .failureResponse(let api, let code) = apiServerError {
                    if let errors = api.errors, errors.contains(code) {
                        errorHandler?(code)
                    }
                }
        })
    }
}

struct EmptyModel : Decodable{
}
