//
//  KeywordViewController.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/30.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit
import Toaster
import Firebase

class KeywordViewController: UIViewController {

    @IBOutlet weak var keywordTableView: UITableView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var keyList : [AlertKeyword] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        requestData()
    }
    
    lazy var addFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45)).then{
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 130, height: 33))
        button.setImage(UIImage(named: "Plusbtn"), for: .normal)
        button.setImage(UIImage(named: "PlusbtnP"), for: .highlighted)
        button.center = $0.center
        $0.addSubview(button)
        button.addTarget(self, action: #selector(self.addKeywordAction), for: .touchUpInside)
    }
    
    lazy var fullAddKeyword = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45)).then{
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width , height: 33))
        label.text = "키워드는 10개까지 저장할 수 있어요"
        label.textAlignment = .center
        label.center = $0.center
        $0.addSubview(label)
    }
    
    func configure(){
        self.navigationItem.hidesBackButton = true
        let image = #imageLiteral(resourceName: "back").resizeImage(size: CGSize(width: 35, height: 35))
        
        let leftButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.backTabAction))
        
        leftButton.image = leftButton.image?.withRenderingMode(.alwaysOriginal)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationController?.navigationBar.tintColor = .clear
//        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.2549019608, green: 0.7843137255, blue: 0.1764705882, alpha: 1)
        keywordTableView.dataSource = self
        keywordTableView.delegate = self
        
        self.title = "키워드 알림 등록"
    }
    
    @objc func backTabAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func requestData(){
        NetworkService.Keyword.getKeyword().on(next: {
            self.keyList = $0
            self.keywordTableView.reloadData()
        })
    }
    
    func subscribeTopic(topic : String, unon : Bool){
        if unon{
            Messaging.messaging().subscribe(toTopic: topic.topicUTF8())
        }else{
            Messaging.messaging().unsubscribe(fromTopic: topic.topicUTF8())
        }
    }
    
    @objc func addKeywordAction(_ sender : UIButton){
        AlertService.shared().alertInit(title: "키워드 추가", message: "", preferredStyle: .alert)
            .addTextField()
            .addAction(title: "취소", style: .cancel)
            .addAction(title: "추가", style: .default){ alert in
                if let tf = AlertService.shared().vc?.textFields?.get(0), let keyword = tf.text?.trimmingCharacters(in: .whitespacesAndNewlines){
                    NetworkService.Keyword.registKeyword(keyword: keyword).on(next: {[weak self] _ in
                        guard let `self` = self else { return }
                        self.subscribeTopic(topic: keyword, unon: true)
                        self.requestData()
                    }, error: { error in
                        Toast.init(text: "이미 등록되어 있는 키워드에요!").show()
                    })
                }
            }
            .showAlert()
    }
    
    
}

extension KeywordViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return keyList.count < 10 ? self.addFooterView : self.fullAddKeyword
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if let keywordCell = tableView.dequeueReusableCell(withIdentifier: KeywordCell.identifier, for: indexPath) as? KeywordCell, let keyModel = keyList.get(indexPath.item){
            keywordCell.keywordLabel?.text = keyModel.keyword
            keywordCell.alertSwitch.isOn = keyModel.alert
            keywordCell.keywordLabel.textColor = keyModel.alert ? .black : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            keywordCell.delegate = self
            keywordCell.model = keyModel
            cell = keywordCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if let model = keyList.get(indexPath.item){
                NetworkService.Keyword.deleteKeyword(keyword: model.keyword).on(next:{[weak self] _ in
                    guard let `self` = self else { return }
                    self.keyList.remove(at: indexPath.item)
                    self.subscribeTopic(topic: model.keyword, unon: false)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.reloadData()
                })
            }
        }
    }
}


extension KeywordViewController : keywordUpdate{
    func updateComplete() {
        requestData()
    }
}
