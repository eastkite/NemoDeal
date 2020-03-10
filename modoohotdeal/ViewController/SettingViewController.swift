//
//  SettingViewController.swift
//  modoohotdeal
//
//  Created by baedy on 2020/02/10.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

struct Setting {
    let title : String
    var value : Bool = false
    let key : UserDefaultsKey
}

enum UserDefaultsKey : String {
    case containEnd
}

class SettingViewController: UIViewController {
    
    var setData : [Setting] = [Setting(title: "종료된 딜 보기", value: true, key: .containEnd)]

    @IBOutlet weak var settingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
   
         configure()

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
        
        settingTableView.delegate = self
        settingTableView.dataSource = self
        
        
        self.title = "설정"
        
        
        if let containEnd = UserDefaults.standard.string(forKey: UserDefaultsKey.containEnd.rawValue){
            setData[0].value = (containEnd == "0") ? false : true
        }else{
            UserDefaults.standard.set("1", forKey: UserDefaultsKey.containEnd.rawValue)
        }
        
        settingTableView.reloadData()
    }
    
    @objc func backTabAction(){
        self.navigationController?.popViewController(animated: true)
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

//MARK: TableView
extension SettingViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier) as? SettingCell{
            if let data = self.setData.get(indexPath.item){
                cell.data = data
                cell.titleLabel.text = data.title
                cell.valueSwitch.isOn = data.value
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    
}
