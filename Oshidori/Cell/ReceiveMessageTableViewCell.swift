//
//  ReceiveMessageTableViewCell.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/8.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class ReceiveMessageTableViewCell: UITableViewCell {

    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContentLabel(content: String) {
        contentLabel.text = content
    }
    
    func setDataLabel(date: String) {
        dateLabel.text = date
    }

    
}
