//
//  ArticleCell.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/24.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit
import AlamofireImage
import GoogleMobileAds

class ArticleCell: UITableViewCell {
    static let identifier = String(describing: ArticleCell.self)
    
    @IBOutlet weak var commentView: UIView! // color
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var siteIcon: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var articleIdLabel: UILabel!
    //    @IBOutlet weak var thumbNailImageView: UIImageView!
//    @IBOutlet weak var commentLabel: UILabel!
//    @IBOutlet weak var recommendLabel: UILabel!
//
//    @IBOutlet weak var unlikeView: UIView!
//    @IBOutlet weak var decommendLabel: UILabel!
    
    @IBOutlet weak var endArticleView: UIView!
    @IBOutlet weak var regDateLabel: UILabel!
    
    //    @IBOutlet weak var adTitle: UILabel!
//    @IBOutlet weak var adIconImage: UIImageView!
//    @IBOutlet weak var adDescLabel: UILabel!
//    @IBOutlet weak var adMediaView: GADMediaView!
//    @IBOutlet weak var adChoiceView: GADAdChoicesView!
    
    var deal : Deal!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func dataToViewSet(data : Deal, row : Int){
        self.deal = data
        
//        adView.isHidden = !deal.adUse
        self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: deal.adUse ? 210 : 105)
        
        siteIcon.image = nil
        siteIcon.setImage(withUrl: data.siteIcon)
        
        categoryLabel.text = "카테고리 - [\(data.category)]"
        commentLabel.text = "[\(data.comment) / \(data.recommend)]"
        let makeTitle = "\(data.title)"
        self.titleLabel.text = makeTitle
        
        articleIdLabel.text = "\(data.id)"
        
//        recommendLabel.text = "\(data.recommend)"
//
//        unlikeView.isHidden = (data.decommend == 0)
//        decommendLabel.text = "\(data.decommend)"
//
//        self.thumbNailImageView?.image = nil
//        if let thumbnail = data.thumbnail {
//            thumbNailImageView.isHidden = false
//            thumbNailImageView.setImage(withUrl: thumbnail)
//        }else{
//            thumbNailImageView.isHidden = true
//            thumbNailImageView.image = nil
//        }
        
        endArticleView.isHidden = !data.end
        
        regDateLabel.text = data.isToday() ? data.time : data.day
        
        let hot = data.recommend + data.comment
        self.commentLabel.textColor = UIColor.lightGray
        self.contentView.backgroundColor = .clear
        self.titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        if hot > 100 {
//            self.titleLabel.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            self.contentView.backgroundColor = #colorLiteral(red: 0.8823562052, green: 0.02745098062, blue: 0.2172963142, alpha: 0.2)
            self.commentLabel.textColor = #colorLiteral(red: 0.7969017551, green: 0.236141049, blue: 0.2498840711, alpha: 1)
        }else if hot >= 80 {
//            self.titleLabel.textColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
            self.contentView.backgroundColor = #colorLiteral(red: 0.6278627997, green: 0.253661468, blue: 0.8935921135, alpha: 0.2)
            self.commentLabel.textColor = #colorLiteral(red: 0.4667701199, green: 0.2792126237, blue: 0.852855142, alpha: 1)
        }else if hot >= 50 {
//            self.titleLabel.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            self.contentView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.2)
            self.commentLabel.textColor = #colorLiteral(red: 0.1756946938, green: 0.6542433647, blue: 0.8444055678, alpha: 1)
        }else if hot >= 25 {
//            self.titleLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            self.contentView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 0.2)
            self.commentLabel.textColor = #colorLiteral(red: 0.289098698, green: 0.6779751712, blue: 0.4208226313, alpha: 1)
        }else if hot >= 10 {
//            self.titleLabel.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            self.contentView.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 0.2)
            self.commentLabel.textColor = #colorLiteral(red: 0.734187714, green: 0.6469583082, blue: 0.1461500027, alpha: 1)
        }
        
    }
}
