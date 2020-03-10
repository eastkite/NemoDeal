//
//  AdCell.swift
//  modoohotdeal
//
//  Created by baedy on 2020/02/07.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdCell: UITableViewCell {
    static let identifier = String(describing: AdCell.self)
    
    @IBOutlet weak var adView: GADUnifiedNativeAdView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(row : Int){
                
        DispatchQueue.main.async {
            AdService.shared().nativeAdInit(setAdView: self.adView, row: row)
        }
    }
}
