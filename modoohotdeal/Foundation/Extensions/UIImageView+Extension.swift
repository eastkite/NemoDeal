//
//  UIImageView+Extension.swift
//  modoohotdeal
//
//  Created by baedy on 2020/01/17.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

extension UIImageView {
    
    func setImage(withUrl url: String, placeHolderImage: UIImage? = nil, transition: UIImageView.ImageTransition = .noTransition, completion: ((URL?) -> Void)? = nil) {
            setImage(withURL: URL(string: url), placeHolderImage: placeHolderImage, transition: transition, completion: completion)
        
        
    }
    
    func setImage(withURL url: URL?, placeHolderImage: UIImage? = nil,  transition: ImageTransition = .noTransition, completion: ((URL?) -> Void)? = nil) {
        
        guard let url = url else {
            image = placeHolderImage
            return
        }
        
        af_setImage(withURL: url, placeholderImage: placeHolderImage, imageTransition: transition, completion: { response in
            switch response.result {
            case .success(_):
                break
            case .failure(_):
                self.image  = placeHolderImage
            }
            
            completion?(response.request?.url)
        })
    }
    
}
