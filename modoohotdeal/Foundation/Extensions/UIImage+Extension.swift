//
//  UIImage+Extension.swift
//  modoohotdeal
//
//  Created by baedy on 2020/01/03.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeImage(size: CGSize) -> UIImage {
        let originalSize = self.size
        let ratio: CGFloat = {
            return originalSize.width > originalSize.height ? 1 / (size.width / originalSize.width) :
                1 / (size.height / originalSize.height)
        }()
        
        return UIImage(cgImage: self.cgImage!, scale: self.scale * ratio, orientation: self.imageOrientation)
    }
}
