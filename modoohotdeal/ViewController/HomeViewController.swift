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

class HomeViewController: UIViewController {

    @IBOutlet weak var articleTableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    // rx
    let disposeBag = DisposeBag()
    
    var allArticleList : [Deal] = []{
        didSet{
            let sort = allArticleList.sorted(by: {$0.compareDate(withCompareDeal: $1)})
            articleList = sort
        }
    }
    
    var articleList : [Deal] = []{
        didSet{
             articleListSubject.onNext(articleList)
        }
    }
    
    lazy var rightButton = UIButton(type: .custom).then {
        let image = UIImage(named: "setting")
        $0.setImage(image?.resizeImage(size: CGSize(width: 35, height: 35)), for: .normal)
        $0.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        $0.addTarget(self, action: #selector(self.alertSettingViewPresentAction), for: .touchUpInside)
    }
    
    lazy var barButton: UIBarButtonItem = UIBarButtonItem(customView: self.rightButton)
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func requestData(){
        _ = NetworkService.Hotdeal.getSiteList().bind(to: siteList)
    }
    
    func configure(){
        self.title = "모두의핫딜"
        self.articleTableView.delegate = self
        
        setRefreshControl()
        
        self.navigationItem.rightBarButtonItem = barButton
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
            }.subscribe(onNext: {[weak self] (deals, site) in
                guard let `self` = self else { return }
                print("너는 누구냐 : \(site)")
                self.allArticleList.append(contentsOf: deals)
                
                if let first = deals.first{
                    self.eachDealFirstOne[site] = first
                }
                
                // 각각의 제일 나중의 것을 알고 있기 위함
                if let last = deals.last{
                    self.eachDealLastOne[site] = last
                }
            }).disposed(by: disposeBag)
        
        articleListSubject.asObserver().bind(to: self.articleTableView.rx.items(cellIdentifier: ArticleCell.identifier, cellType: ArticleCell.self)){ index, data, cell in
            cell.dataToViewSet(data: data)
        }.disposed(by: disposeBag)
    }
    
    @objc func alertSettingViewPresentAction(_ sender : Any){
        if let vc = UIStoryboard(name: "Keyword", bundle: .main).instantiateViewController(withIdentifier: "KeywordViewController") as? KeywordViewController{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setRefreshControl(){
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        
        refreshControl.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        self.articleTableView.addSubview(refreshControl)
    }
    
    @objc func refresh(sender: AnyObject){
        self.articleList = []
        self.allArticleList = []
        self.requestData()
//        _ = NetworkService.Hotdeal.getHotDeal(site: currentSite.value)
//            .subscribe(onNext: {[weak self] (deals, site) in
//                guard let `self` = self else { return }
//                self.articleList.append(contentsOf: deals)
//                if self.refreshControl.isRefreshing{
//                    self.refreshControl.endRefreshing()
//                }
//            })
    }
}

extension HomeViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let data = articleList.get(indexPath.item){
            return data.adUser ? 210 : 105
        }
        return 105
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ArticleCell, let url = URL(string: cell.deal.url){
            let vc = UIStoryboard(name: "ArticleWeb", bundle: .main).instantiateViewController(withIdentifier: "ArticleWebViewController") as! ArticleWebViewController
            vc.setURL(url: url)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.articleTableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let element = articleList.get(indexPath.item){
            
            if let containSite = eachDealLastOne.filter({$0.value.id == element.id}).first?.key, let lastDeal = self.eachDealLastOne[containSite], lastDeal.id == element.id{
                LoadingIndicatorPresenter.default.startLoading()
                self.articleTableView.scrollToRow(at: IndexPath(item: indexPath.item - 1, section: indexPath.section), at: .bottom
                    , animated: true)
                
                _ = NetworkService.Hotdeal.getHotDeal(site: containSite, id: lastDeal.id)
                    .on(next: {[weak self] (deals, site) in
                        guard let `self` = self else { return }
                        deals.forEach{ deal in
                            if !self.allArticleList.contains(where: {$0.id == deal.id}){
                                self.allArticleList.append(deal)
                            }
                        }
                        
                        if let first = deals.first{
                            self.eachDealFirstOne[site] = first
                            print("site : \(site) : \(first)")
                        }
                        
                        if let last = deals.last{
                            self.eachDealLastOne[site] = last
                            print("site : \(site) : \(last)")
                        }
                        LoadingIndicatorPresenter.default.stopLoading()
                    })
            }
        }
        
//        if indexPath.item == self.articleList.count - 1{
//            _ = NetworkService.Hotdeal.getHotDeal(site: currentSite.value, id: articleList[indexPath.item].id)
//                .on(next: {[weak self] deals in
//                    guard let `self` = self else { return }
//                    deals.forEach{ deal in
//                        if !self.articleList.contains(where: {$0.id == deal.id}){
//                            self.articleList.append(deal)
//                        }
//                    }
//                })
//        }
    }
}
