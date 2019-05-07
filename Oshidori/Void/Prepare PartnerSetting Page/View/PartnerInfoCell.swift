//
//  PartnerInfoCell.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/6.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class PartnerInfoCell: UITableViewCell {

    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var name: String? {
        didSet {
            infoLabel.text = name
        }
    }
    
    var subTitle: String? {
        didSet {
            subTitleLabel.text = subTitle
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
