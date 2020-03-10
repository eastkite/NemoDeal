//
//  SettingCell.swift
//  modoohotdeal
//
//  Created by baedy on 2020/02/10.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    static let identifier = String(describing: SettingCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueSwitch: UISwitch!
    
    var data : Setting!
    
    @IBAction func switchAction(_ sender: Any) {
        if let value = (sender as? UISwitch)?.isOn{
            UserDefaults.standard.set(value ? "1": "0", forKey: data.key.rawValue)
        }
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
