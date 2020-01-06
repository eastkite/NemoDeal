//
//  ArticleCell.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/24.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit
import AlamofireImage

class ArticleCell: UITableViewCell {
    static let identifier = String(describing: ArticleCell.self)
    
    @IBOutlet weak var siteIcon: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbNailImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var recommendLabel: UILabel!
    
    @IBOutlet weak var unlikeView: UIView!
    @IBOutlet weak var decommendLabel: UILabel!
    
    @IBOutlet weak var endArticleView: UIView!
    @IBOutlet weak var regDateLabel: UILabel!
    
    @IBOutlet weak var adView: UIView!
    
    var ad = false
    
    var deal : Deal!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func randAd(){
        let number = Int.random(in: 0 ..< 5)
        ad = number == 2
    }
    
    func dataToViewSet(data : Deal){
        self.deal = data
        
        adView.isHidden = !deal.adUser
        self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: deal.adUser ? 210 : 105)
        
        siteIcon.af_setImage(withURL: URL(string: data.siteIcon)!)
        
        categoryLabel.text = "[\(data.category)]"
        commentLabel.text = "\(data.comment)"
        let makeTitle = "\(data.title)"
        self.titleLabel.text = makeTitle
        
        recommendLabel.text = "\(data.recommend)"
        
        unlikeView.isHidden = (data.decommend == 0)
        decommendLabel.text = "\(data.decommend)"
        
        self.thumbNailImageView?.image = nil
        if let thumbnail = data.thumbnail {
            thumbNailImageView.isHidden = false
            thumbNailImageView.af_setImage(withURL: URL(string: thumbnail)!)
        }else{
            thumbNailImageView.isHidden = true
            thumbNailImageView.image = nil
        }
        
        endArticleView.isHidden = !data.end
        
        regDateLabel.text = data.isToday() ? data.time : data.day
        
        let hot = data.recommend + data.comment
        self.titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        if hot > 50 {
            self.titleLabel.textColor = #colorLiteral(red: 0.9865689212, green: 0.1557151073, blue: 0.2369613399, alpha: 1)
        }else if hot >= 20 {
            self.titleLabel.textColor = #colorLiteral(red: 0.3433958923, green: 0.6188654144, blue: 0.9121228195, alpha: 1)
        }
    }
}
