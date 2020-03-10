//
//  ArticleViewController.swift
//  modoohotdeal
//
//  Created by baedy on 2020/01/16.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Toaster
import SafariServices

class ArticleViewController: UIViewController {
    
    var toolbarItemIconList = [ "backIcon", "external", "safariIcon"]
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var unlikeView: UIView!
    @IBOutlet weak var unlikeLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var toolbarCollectionView: UICollectionView!
    
    var titleText = ""
    var site = -1
    var articleId = -1
    
    let contents = BehaviorRelay<ArticleContent?>(value: nil)
    var requestData : ArticleContent? = nil
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configure()
        bindData()
        
        dataAccept()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewConfigure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
    }
    
    func dataAccept(){
        if let data = self.requestData{
            self.contents.accept(data)
        }else{
            _ = NetworkService.Hotdeal.getContents(site: self.site, articleId: self.articleId).on(next: {[weak self] data in
                guard let `self` = self else { return }
                self.contents.accept(data)
                }, error: {[weak self] err in
                    guard let `self` = self else { return }
                    if err == .hd_4045{
                        self.noDataArticle(site: self.site, articleId: self.articleId)
                    }
            })
        }
    }
    
    func noDataArticle(site : Int, articleId : Int){
        NetworkService.Hotdeal.deleteArticle(site: site, articleId: articleId).on(next: {_ in
            AlertService.shared().alertInit(title: "안내", message: "삭제된 게시물입니다.", preferredStyle: .alert)
                .addAction(title: "확인", style: .cancel){[weak self] alert in
                    guard let `self` = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
                .showAlert()
        })
    }
    
    func bindData(){
        self.contents.filter{$0 != nil}.map{$0!.imgList.count == 0 ? [""] : $0!.imgList}.bind(to: imageCollectionView.rx.items(cellIdentifier: ImageCollectionViewCell.identifier, cellType: ImageCollectionViewCell.self)){ index, data, cell in
            cell.setImage(imageSrc: data)
        }.disposed(by: disposeBag)
        
        self.contents.filter{$0 != nil}.map{$0!.imgList.count == 0 ? 1 : $0!.imgList.count}.bind(to: pageControl.rx.numberOfPages).disposed(by: disposeBag)
        
        self.contents.filter{$0 != nil}.map{$0!.mainContent.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? "본문 내용이 없습니다. 네모딜 많이 사랑해 주세요!" : $0!.mainContent.trimmingCharacters(in: .whitespacesAndNewlines)}.bind(to: contentLabel.rx.text).disposed(by: disposeBag)
        
        self.contents.filter{$0 != nil}.map{ $0!.deal }.subscribe(onNext: { [weak self] deal in
            guard let `self` = self else { return }
            self.dataToViewSet(data: deal)
        }).disposed(by: disposeBag)
    }
    
    func dataToViewSet(data : Deal){
        
        let category = "[\(data.category)] - "
        commentLabel.text = "\(data.comment)"
        let makeTitle = category + "\(data.title)"
        self.titleLabel.text = makeTitle
        
        likeLabel.text = "\(data.recommend)"
        
        unlikeView.isHidden = (data.decommend == 0)
        unlikeLabel.text = "\(data.decommend)"
//
//        let hot = data.recommend + data.comment
//        self.titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        if hot > 50 {
//            self.titleLabel.textColor = #colorLiteral(red: 0.9865689212, green: 0.1557151073, blue: 0.2369613399, alpha: 1)
//        }else if hot >= 20 {
//            self.titleLabel.textColor = #colorLiteral(red: 0.3433958923, green: 0.6188654144, blue: 0.9121228195, alpha: 1)
//        }
//
    }
    
    func collectionViewConfigure(){
        // imageCollectionView setting
        // width, height 설정
        let cellWidth = imageCollectionView.frame.width - 60
        let cellHeight = imageCollectionView.frame.height - 20
        
        
        let layout = imageCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .horizontal
        
        // 상하, 좌우 inset value 설정
        let insetX = (imageCollectionView.bounds.width - cellWidth ) / 2.0
        
        imageCollectionView.contentInset = UIEdgeInsets(top: 5, left: insetX, bottom: 15, right: insetX)
        
        imageCollectionView.delegate = self
        //        imageCollectionView.dataSource = self
        
        // 스크롤 시 빠르게 감속 되도록 설정
        imageCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        
        toolbarCollectionView.dataSource = self
        toolbarCollectionView.delegate = self
        
        let toolbarlayout = toolbarCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let width = (toolbarCollectionView.bounds.width - 60) / 3
        toolbarlayout.itemSize = CGSize(width: width, height: toolbarCollectionView.frame.height)
        toolbarlayout.minimumLineSpacing = 0
        
        toolbarCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        toolbarCollectionView.isScrollEnabled = false
        toolbarCollectionView.showsVerticalScrollIndicator = false
        toolbarCollectionView.showsHorizontalScrollIndicator = false
        
    }
    
    
    func configure(){
        
        self.imageCollectionView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9764705882, alpha: 1)
        self.imageCollectionView.layer.cornerRadius = 10.0
        self.imageCollectionView.layer.shadowRadius = 15
        self.imageCollectionView.layer.shadowOpacity = 0.2
        self.imageCollectionView.layer.shadowOffset = CGSize(width: 16, height: 16)
        
        self.title = "상세 정보"
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
        self.navigationItem.hidesBackButton = true
        
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        
        
        // toolbar CollectionView Setting
       
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ArticleViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.toolbarCollectionView {
            return toolbarItemIconList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if collectionView == self.toolbarCollectionView{
            if let toolCell = collectionView.dequeueReusableCell(withReuseIdentifier: ToolBarCell.identifier, for: indexPath) as? ToolBarCell, let src = self.toolbarItemIconList.get(indexPath.item){
                toolCell.setImage(imageSrc: src)
                cell = toolCell
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == toolbarCollectionView{
            let item = indexPath.item
            if item == 0{
                // 뒤로가기
                self.navigationController?.popViewController(animated: true)
            }else if item == 1{
                // 구매 링크
                if let linkString = contents.value?.originLink ,let url = URL(string: linkString){
                    // 클리앙의 경우는 잘 됨
                    self.sfvcCallRequest(url)
                }else if let linkString = contents.value?.originLink?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ,let url = URL(string: linkString){
                    // 뽐뿌의 경우는 잘 안되서 인코딩
                    self.sfvcCallRequest(url)
                }
                else{
                    Toast.init(text: "구매링크를 찾을 수 없네요.").show()
                }
            }else if item == 2{
                // 원본 링크
                if let linkString = contents.value?.articleLink ,let url = URL(string: linkString){
                    self.sfvcCallRequest(url)
                }else{
                    Toast.init(text: "본문링크를 찾을 수 없네요.").show()
                }
            }
        }else if collectionView == imageCollectionView{
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell, let image = contents.value?.imgList.get(indexPath.item) , self.contents.value?.imgList.count != 0{
                self.imageModalViewShow(image)
            }
        }
    }
    
    func sfvcCallRequest(_ url: URL){
        let vc = SFSafariViewController.init(url: url)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    func imageModalViewShow(_ image : String){
        if let vc = UIStoryboard(name: "ModalImage", bundle: .main).instantiateViewController(withIdentifier: "ModalImageViewController") as? ModalImageViewController{
            vc.modalPresentationStyle = .overFullScreen
            vc.setImage(image)
            self.present(vc, animated: true)
        }
    }
    
}

extension ArticleViewController : UIScrollViewDelegate{
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        // item의 사이즈와 item 간의 간격 사이즈를 구해서 하나의 item 크기로 설정.
        let layout = self.imageCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        // targetContentOff을 이용하여 x좌표가 얼마나 이동했는지 확인
        // 이동한 x좌표 값과 item의 크기를 비교하여 몇 페이징이 될 것인지 값 설정
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        var roundedIndex = round(index)
        
        // scrollView, targetContentOffset의 좌표 값으로 스크롤 방향을 알 수 있다.
        // index를 반올림하여 사용하면 item의 절반 사이즈만큼 스크롤을 해야 페이징이 된다.
        // 스크로로 방향을 체크하여 올림,내림을 사용하면 좀 더 자연스러운 페이징 효과를 낼 수 있다.
        if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            roundedIndex = floor(index)
        } else {
            roundedIndex = ceil(index)
        }
        
        // 위 코드를 통해 페이징 될 좌표값을 targetContentOffset에 대입하면 된다.
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
        
        self.pageControl.currentPage = Int(roundedIndex)
    }
}
