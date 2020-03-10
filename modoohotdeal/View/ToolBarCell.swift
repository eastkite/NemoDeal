//
//  toolBarCell.swift
//  modoohotdeal
//
//  Created by baedy on 2020/01/17.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

class ToolBarCell: UICollectionViewCell {
    static let identifier = String(describing: ToolBarCell.self)
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setImage(imageSrc : String){
        self.imageView?.image = #imageLiteral(resourceName: imageSrc)
    }
}
