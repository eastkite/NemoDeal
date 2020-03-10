//
//  VersionInfoViewController.swift
//  modoohotdeal
//
//  Created by baedy on 2020/02/06.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

class VersionInfoViewController: UIViewController {
    var currentVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    @IBOutlet weak var versionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        let image = #imageLiteral(resourceName: "back").resizeImage(size: CGSize(width: 35, height: 35))
        
        let leftButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.backTabAction))
        
        leftButton.image = leftButton.image?.withRenderingMode(.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.title = "버전 정보"
        
        versionLabel.text = "현재 버전 : v\(currentVersion)"
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
