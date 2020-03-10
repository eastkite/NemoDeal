//
//  ImageCollectionViewCell.swift
//  modoohotdeal
//
//  Created by baedy on 2020/01/17.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

class ImageCollectionViewCell : UICollectionViewCell{
    static let identifier = String(describing: ImageCollectionViewCell.self)
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.imageView.image = #imageLiteral(resourceName: "noImage")
    }
    
    func setImage(imageSrc : String){
        imageView.setImage(withUrl: imageSrc, placeHolderImage: #imageLiteral(resourceName: "defaultImageNoneAlpha"), transition: .noTransition)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 3.0
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 5, height: 10)
        self.clipsToBounds = false
        
//        imageView.clipsToBounds = false
    }
}
