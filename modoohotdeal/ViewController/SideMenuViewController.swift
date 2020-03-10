//
//  SideMenuViewController.swift
//  modoohotdeal
//
//  Created by baedy on 2020/02/03.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import SideMenu

protocol SideMenuProtocol : class {
    func sideMenuTabImplement(index : Int)
}

struct SideMenuItem {
    let title : String
    let imageIcon : String
}

class SideMenuViewController: UIViewController {

    
    weak var delegate : SideMenuProtocol?
    
    let sideMenuList : [SideMenuItem] = [
        SideMenuItem(title: "키워드 알림 등록", imageIcon: "plus"),
        SideMenuItem(title: "오픈소스 라이센스", imageIcon: "license"),
        SideMenuItem(title: "개발자에게 연락", imageIcon: "mail"),
        SideMenuItem(title: "버전", imageIcon: "version"),
        SideMenuItem(title: "설정", imageIcon: "setting")
    ]
    
    @IBOutlet weak var menuTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "메뉴"
        
        // Do any additional setup after loading the view.
        menuTableView.dataSource = self
        menuTableView.delegate = self
    }
    
}

extension SideMenuViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sideMenuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as? menuCell, let item = sideMenuList.get(indexPath.item){
            cell.menuLabel?.text = item.title
            cell.iconImageView.image = UIImage(named: item.imageIcon)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let side = self.navigationController as? SideMenuNavigationController{
            side.dismiss(animated: true){[weak self] in
                self?.delegate?.sideMenuTabImplement(index: indexPath.item)
            }
        }
    }
}

class menuCell : UITableViewCell{
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!
}
