//
//  CarteCustomViewController.swift
//  modoohotdeal
//
//  Created by baedy on 2020/02/12.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import Carte

class CarteCustomViewController: CarteViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = #imageLiteral(resourceName: "back").resizeImage(size: CGSize(width: 35, height: 35))
        
        let leftButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.backTabAction))
        
        leftButton.image = leftButton.image?.withRenderingMode(.alwaysOriginal)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationController?.navigationBar.tintColor = .clear
        
        self.title = "오픈소스 라이센스"
    }
    
    @objc func backTabAction(){
        self.navigationController?.popViewController(animated: true)
    }
}
