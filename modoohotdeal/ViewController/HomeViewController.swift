//
//  HomeViewController.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/24.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SideMenu
import Carte
import MessageUI
import Toaster

enum HomeType{
    case main
    case search
}

class HomeViewController: UIViewController {

    @IBOutlet weak var articleTableView: UITableView!
    let refreshControl = UIRefreshControl()
    var type : HomeType = .main
    // rx
    let disposeBag = DisposeBag()
    let adfrequent = 6
    
    var adLoadDic : [Int:Bool] = [:]
    
    var dealCount = 0
    
    var allArticleList : [Deal] = []{
        didSet{
            var sort : [Deal?] = allArticleList.sorted(by: {$0.compareDate(withCompareDeal: $1)})
//            let adRate = allArticleList.count / 9
//            for i in 1 ..< adRate{
//                if let _ = sort.get(i * 9){
//                    sort[i * 6].adUse = true
//                }
//            }
            
            
            if sort.count > adfrequent{
                let bound = 1...((sort.count) / adfrequent)
                
                for i in bound.reversed(){
                    Log.d("광고 추가 : \(i * adfrequent)")
                    sort.insert(nil, at: i * adfrequent)
                }
            }
            
            articleList = sort
            
            
//            self.articleTableView.beginUpdates()
            
//            self.articleTableView.endUpdates()
        }
    }
    
    lazy var sideMenuNavigation : SideMenuNavigationController? = nil
    
    var articleList : [Deal?] = []{
        didSet{
            Log.d("현재 딜 갯수 광고포함 - \(articleList.count)")
            self.articleTableView.reloadData()
//            self.dealCount = articleList.count
//            if dealCount < 50 {
////                DispatchQueue.main.async { [weak self] in
////                    guard let `self` = self else { return }
//
////                }
//            }else{
//                let temp = dealCount
//                var indexPaths : [IndexPath] = []
//                for row in temp - 1 ..< dealCount - 1{
//                    indexPaths.append(IndexPath(row: row, section: 0))
//                }
////                DispatchQueue.main.async { [weak self] in
////                    guard let `self` = self else { return }
//                    self.articleTableView.reloadRows(at: indexPaths, with: .none)
////                }
//            }
        }
    }
    
    lazy var leftButton = UIButton(type: .custom).then {
        let image = UIImage(named: "Tab_Menu")
        $0.setImage(image?.resizeImage(size: CGSize(width: 35, height: 35)), for: .normal)
        $0.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        $0.addTarget(self, action: #selector(self.sideMenuPresent(_:)), for: .touchUpInside)
    }
    
    lazy var searchButton = UIButton(type: .custom).then {
        let image = UIImage(named: "search")
        $0.setImage(image?.resizeImage(size: CGSize(width: 35, height: 35)), for: .normal)
        $0.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        $0.addTarget(self, action: #selector(self.searchAction), for: .touchUpInside)
    }
    
    lazy var returnButton = UIButton(type: .custom).then {
        let image = UIImage(named: "return")
        $0.setImage(image?.resizeImage(size: CGSize(width: 35, height: 35)), for: .normal)
        $0.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        $0.addTarget(self, action: #selector(self.returnAction), for: .touchUpInside)
    }

    lazy var searchBarButton: UIBarButtonItem = UIBarButtonItem(customView: self.searchButton)
    lazy var returnBarButton: UIBarButtonItem = UIBarButtonItem(customView: self.returnButton)
//
    lazy var sideButton: UIBarButtonItem = UIBarButtonItem(customView: self.leftButton)
    
    // model
    let siteList = BehaviorRelay<[DealSite]>(value: [])
    var eachDealFirstOne : [Int : Deal] = [:]
    
    /// 각 테이블 별로 마지막 id 데이터 들고있기 위한 모델
    var eachDealLastOne : [Int : Deal] = [:]
    /// 테이블에 보이는 딜 전체 리스트
    let articleListSubject = PublishSubject<[Deal]>()
    let currentSite = BehaviorRelay<Int?>(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        databind()
        configure()
        requestData()
        adDidLoadNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
    }
    
    @objc func requestData(){
        _ = NetworkService.Hotdeal.getSiteList().bind(to: siteList)
    }
    
    func configure(){
        self.title = "네모딜"
        self.articleTableView.delegate = self
        self.articleTableView.dataSource = self
        self.articleTableView.prefetchDataSource = self
        
        setRefreshControl()
        
        self.navigationItem.rightBarButtonItem = searchBarButton
        self.navigationItem.leftBarButtonItem = sideButton
        
        if let vc = UIStoryboard(name: "SideMenu", bundle: .main).instantiateViewController(withIdentifier: "SideMenu") as? SideMenuNavigationController{
            let style : SideMenuPresentationStyle = .menuSlideIn
            style.backgroundColor = .clear
            style.onTopShadowOffset = CGSize(width: 5, height: 5)
            style.onTopShadowOpacity = 7
            style.onTopShadowColor = .gray
            style.menuStartAlpha = 0.5
            
            vc.presentationStyle = style
            vc.leftSide = true
            
            if let sideVC = vc.topViewController as? SideMenuViewController{
                sideVC.delegate = self
            }
            vc.sideMenuManager.addScreenEdgePanGesturesToPresent(toView: self.view)
            
            self.sideMenuNavigation = vc
        }
    }
    
    
    func databind(){
        self.siteList.subscribe(onNext: {[weak self] list in
            guard let `self` = self else { return }
            list.forEach({self.currentSite.accept($0.id)})
            
            if self.refreshControl.isRefreshing{
                self.refreshControl.endRefreshing()
            }
        }).disposed(by: disposeBag)
        
        currentSite.filter{ $0 != nil }.asObservable().flatMap{
                NetworkService.Hotdeal.getHotDeal(site: $0!)
            }.subscribe(onNext: {[weak self] deals in
                guard let `self` = self else { return }
//                print("너는 누구냐 : \(site)")
                self.allArticleList.append(contentsOf: deals)
                
                if let first = deals.first {
                    let site = first.siteId
                    self.eachDealFirstOne[site] = first
                }
//
//                // 각각의 제일 나중의 것을 알고 있기 위함
                if let last = deals.last{
                    let site = last.siteId
                    self.eachDealLastOne[site] = last
                }
            }).disposed(by: disposeBag)
        
//        articleListSubject.asObserver().bind(to: self.articleTableView.rx.items(cellIdentifier: ArticleCell.identifier, cellType: ArticleCell.self)){ index, data, cell in
//            cell.dataToViewSet(data: data, row: index)
//        }.disposed(by: disposeBag)
    }
    
//    @objc func alertSettingViewPresentAction(_ sender : Any){
//        AdService.shared().loadInterstitialAdFromKeyword{
//            if let vc = UIStoryboard(name: "Keyword", bundle: .main).instantiateViewController(withIdentifier: "KeywordViewController") as? KeywordViewController{
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
//    }
    
    @objc func sideMenuPresent(_ sender : Any){
  
        self.present(sideMenuNavigation!, animated: true)
    }
    
    func setRefreshControl(){
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        refreshControl.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        self.articleTableView.addSubview(refreshControl)
    }
    
    @objc func refresh(){
        self.adLoadDic = [:]
        self.articleList = []
        self.allArticleList = []
        self.requestData()
    }
}

//MARK: Search
extension HomeViewController{
    
    func homeViewSetting(withType type: HomeType){
        self.type = type
        switch type {
        case .main:
            self.navigationItem.rightBarButtonItem = searchBarButton
            self.articleTableView.addSubview(refreshControl)
        case .search:
            self.navigationItem.rightBarButtonItem = returnBarButton
            self.refreshControl.removeFromSuperview()
        }
        
        self.articleTableView.setContentOffset(.zero, animated: true)
    }
    
    @objc func searchAction(){
        AlertService.shared().alertInit(title: "검색", message: "키워드를 입력해 주세요", preferredStyle: .alert).addTextField()
            .addAction(title: "닫기", style: .cancel)
            .addAction(title: "찾기", style: .destructive){[weak self] alert in
                guard let `self` = self else { return }
                if let tf = AlertService.shared().vc?.textFields?.get(0), let keyword = tf.text?.trimmingCharacters(in: .whitespacesAndNewlines){
                    self.searchKeyword(key: keyword)
                }else{
                    Toast.init(text: "검색에 실패했어요.").show()
                }
            }.showAlert()
    }
    
    func searchKeyword(key : String){
        _ = NetworkService.Hotdeal.getSearch(withKeyword: key).on(next: {[weak self] deals in
            guard let `self` = self else { return }

            DispatchQueue.main.async {
                self.articleTableView.setContentOffset(.zero, animated: true)
            }
            
            self.articleList = []
            self.allArticleList = []
            
            self.allArticleList = deals
            self.homeViewSetting(withType: .search)
            }, error: { e in
                Log.e("\(e.code) : 데이터 없음?")
                Toast.init(text: "검색 키워드의 핫딜을 찾을 수 없습니다").show()
        })
    }
    
    @objc func returnAction(){
        self.homeViewSetting(withType: .main)
        self.refresh()
    }
    //
}

extension HomeViewController : SideMenuProtocol{
    @objc func backTabAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func sideMenuTabImplement(index: Int) {
        if index == 0 {
            // 키워드 등록
            AdService.shared().loadInterstitialAdFromKeyword{
                if let vc = UIStoryboard(name: "Keyword", bundle: .main).instantiateViewController(withIdentifier: "KeywordViewController") as? KeywordViewController{
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else if index == 1{
            // 오픈소스 라이센스
            let carteVC = CarteCustomViewController()
            
            self.navigationController?.pushViewController(carteVC, animated: true)
        }else if index == 2{
            // 메일 보내기
            launchEmail()
        }else if index == 3{
            // 버전 정보
            if let vc = UIStoryboard(name: "VersionInfo", bundle: .main).instantiateViewController(withIdentifier: "VersionInfoViewController") as? VersionInfoViewController{
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if index == 4{
            if let vc = UIStoryboard(name: "Setting", bundle: .main).instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController{
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension HomeViewController{
    func deletedArticle(id: Int) {
        if let index = self.allArticleList.firstIndex(where: {$0.id == id}){
            self.allArticleList.remove(at: index)
        }
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching{
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        if type == .main {
            for index in indexPaths {
                let item = index.item
                if let element = articleList.get(item), element != nil{
                    if let containSite = eachDealLastOne.filter({$0.value.id == element!.id}).first?.key, let lastDeal = self.eachDealLastOne[containSite], lastDeal.id == element!.id{
                        LoadingIndicatorPresenter.default.startLoading()
                        //                    self.articleTableView.scrollToRow(at: IndexPath(item: item - 1, section: indexPath.section), at: .bottom
                        //                        , animated: true)
                        
                        _ = NetworkService.Hotdeal.getHotDeal(site: containSite, id: lastDeal.id)
                            .on(next: {[weak self] deals in
                                guard let `self` = self else { return }
                                var newDeal : [Deal] = []
                                deals.forEach{ deal in
                                    if !self.allArticleList.contains(where: {$0.id == deal.id}){
                                        newDeal.append(deal)
                                        
                                    }
                                }
                                
                                self.allArticleList.append(contentsOf: newDeal)
                                
                                if let first = deals.first{
                                    let site = first.siteId
                                    self.eachDealFirstOne[site] = first
                                    print("site : \(site) : \(first)")
                                }
                                
                                if let last = deals.last{
                                    let site = last.siteId
                                    self.eachDealLastOne[site] = last
                                    print("site : \(site) : \(last)")
                                }
                                LoadingIndicatorPresenter.default.stopLoading()
                            })
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 0 , (indexPath.row + 1) % (adfrequent + 1) == 0 {
            // 광고 셀
//            Log.d("ad index : \(indexPath.row)")
            if self.adLoadDic[indexPath.row] ?? false {
                return 120
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }else{
            // 일반 셀
//            Log.d("ad not index : \(indexPath.row)")
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.articleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier) as? ArticleCell, let deal = articleList.get(indexPath.row), deal != nil{
            cell.dataToViewSet(data: deal!, row: indexPath.row)
            return cell
        }else if let cell = tableView.dequeueReusableCell(withIdentifier: AdCell.identifier) as? AdCell, let deal = articleList.get(indexPath.row), deal == nil{
            if !(self.adLoadDic[indexPath.row] ?? false) {
                Log.d("광고 셀 세팅 \(indexPath.item)")
                cell.setCell(row: indexPath.row)
                self.adLoadDic[indexPath.row] = false
            }
            //cell.clipsToBounds = true
            
            return cell
        }
        return UITableViewCell()
    }
    
    
    func noDataArticle(site : Int, articleId : Int){
        NetworkService.Hotdeal.deleteArticle(site: site, articleId: articleId).on(next: {_ in
            AlertService.shared().alertInit(title: "안내", message: "삭제된 게시물이네요.\n보이지 않게 처리해드릴게요.", preferredStyle: .alert)
                .addAction(title: "확인", style: .cancel){[weak self] alert in
                    guard let `self` = self else { return }
                    self.deletedArticle(id: articleId)
//                    self.navigationController?.popViewController(animated: true)
                }
                .showAlert()
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            
        if let cell = tableView.cellForRow(at: indexPath) as? ArticleCell, let deal = cell.deal{
//                if deal.siteId == 0{
            
            _ = NetworkService.Hotdeal.getContents(site: deal.siteId, articleId: deal.id).on(next: {[weak self] data in
                guard let `self` = self else { return }
                
                AdService.shared().loadInterstitialAd {
                    let vc = UIStoryboard(name: "ArticleMain", bundle: .main).instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
                    vc.titleText = deal.title
                    vc.articleId = deal.id
                    vc.site = deal.siteId
                    vc.requestData = data
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                }, error: {[weak self] err in
                    guard let `self` = self else { return }
                    if err == .hd_4045{
                        self.noDataArticle(site: deal.siteId, articleId: deal.id)
                    }
            })
            
        }
        self.articleTableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//        if type == .main {
//
//            if let element = articleList.get(indexPath.item), element != nil{
//                if let containSite = eachDealLastOne.filter({$0.value.id == element!.id}).first?.key, let lastDeal = self.eachDealLastOne[containSite], lastDeal.id == element!.id{
//                    LoadingIndicatorPresenter.default.startLoading()
//                    self.articleTableView.scrollToRow(at: IndexPath(item: indexPath.item - 1, section: indexPath.section), at: .bottom
//                        , animated: true)
//
//                    _ = NetworkService.Hotdeal.getHotDeal(site: containSite, id: lastDeal.id)
//                        .on(next: {[weak self] deals in
//                            guard let `self` = self else { return }
//                            var newDeal : [Deal] = []
//                            deals.forEach{ deal in
//                                if !self.allArticleList.contains(where: {$0.id == deal.id}){
//                                    newDeal.append(deal)
//
//                                }
//                            }
//
//                            self.allArticleList.append(contentsOf: newDeal)
//
//                            if let first = deals.first{
//                                let site = first.siteId
//                                self.eachDealFirstOne[site] = first
//                                print("site : \(site) : \(first)")
//                            }
//
//                            if let last = deals.last{
//                                let site = last.siteId
//                                self.eachDealLastOne[site] = last
//                                print("site : \(site) : \(last)")
//                            }
//                            LoadingIndicatorPresenter.default.stopLoading()
//                        })
//                }
//            }
//        }
    }
}

extension HomeViewController {
    func adDidLoadNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadAd(_:)), name: Notification.Name.init("adDidLoad"), object: nil)
    }
    
    @objc func loadAd(_ noti : Notification){
        guard let row = noti.userInfo?["row"] as? Int else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            Log.d("광고 로드 됐어요 = \(row)")
            if self.adLoadDic[row] == false{
                self.adLoadDic[row] = true
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.articleTableView.visibleCells.forEach{
                        if $0 is AdCell{
//                            self.articleTableView.beginUpdates()
//                            self.articleTableView.reloadData()
//                            self.articleTableView.endUpdates()
//
                            self.articleTableView.setContentOffset(self.articleTableView.contentOffset, animated: false)
                            self.articleTableView.reloadRows(at: [IndexPath.init(item: row, section: 0)], with: .none)
//
                            return
                        }
                    }
                })
            }
        }
        
//        if let cell = articleTableView.cellForRow(at: IndexPath(row: row, section: 0)) as? ArticleCell{
//            cell.adViewHeight.priority = .required
//            cell.heightAnchor.constraint(equalToConstant: 260)
//        }
//
        
        
//        self.articleTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }
}


extension HomeViewController : MFMailComposeViewControllerDelegate {
    
    func launchEmail() {
        if !MFMailComposeViewController.canSendMail() {
            Toast.init(text: "메일을 보낼 수 없는 기기에요.").show()
            return
        }
        
        let emailTitle = "버그 및 문의"
        let messageBody = ""
        let toRecipents = ["eastkite13@gmail.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            Toast.init(text: "메일 전송 완료!").show()
        case .failed:
            Toast.init(text: "메일 전송을 실패했어요.").show()
        case .cancelled:
            Toast.init(text: "메일 전송 취소.").show()
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
