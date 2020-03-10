//
//  KeywordCell.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/30.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit
import Firebase

protocol keywordUpdate: class {
    func updateComplete()
}

class KeywordCell: UITableViewCell {
    static let identifier = String(describing: KeywordCell.self)
    
    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var alertSwitch: UISwitch!
    
    weak var delegate : keywordUpdate?
    
    var model : AlertKeyword!
    
    @IBAction func switchAction(_ sender: Any) {
        Feedback.notification(type: .success).occurred()
        let unon = (sender as! UISwitch).isOn
        NetworkService.Keyword.updateAlert(keyword: model.keyword, alert: unon).on(next: {[weak self]
            _ in
            guard let `self` = self else { return }
            self.subscribeTopic(topic: self.model.keyword, unon: unon)
            self.delegate?.updateComplete()
        })
    }
    
    func subscribeTopic(topic : String, unon : Bool){
        if unon{
            Messaging.messaging().subscribe(toTopic: topic.topicUTF8())
        }else{
            Messaging.messaging().unsubscribe(fromTopic: topic.topicUTF8())
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
