//
//  MessageReportTableViewCell.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/29.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class MessageReportTableViewCell: UITableViewCell {

    @IBOutlet weak var messageCountLabel: UILabel!
    @IBOutlet weak var courageCountLabel: UILabel!
    @IBOutlet weak var supportCountLabel: UILabel!
    @IBOutlet weak var messageReportView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessageCountLabel(messageCount: String) {
        messageCountLabel.text = messageCount
    }
    
    func setCourageCountLabel(courageCount: String) {
        courageCountLabel.text = courageCount
    }
    
    func setSupportCountLabel(supportCount: String) {
        supportCountLabel.text = supportCount
    }
    
    
    
}
