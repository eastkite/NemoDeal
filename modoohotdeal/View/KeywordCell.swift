//
//  KeywordCell.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/30.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit

class KeywordCell: UITableViewCell {
    static let identifier = String(describing: KeywordCell.self)
    
    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var alertSwitch: UISwitch!
    
    var model : AlertKeyword!
    
    @IBAction func switchAction(_ sender: Any) {
        Feedback.notification(type: .success).occurred()
        
        NetworkService.Keyword.updateAlert(keyword: model.keyword, alert: (sender as! UISwitch).isOn).on()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
