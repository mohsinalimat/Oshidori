//
//  SubTitleCell.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/26.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class SubTitleCell: UITableViewCell {

    @IBOutlet weak var subtitleLabel: UILabel!
    
    var title: String? {
        didSet {
            guard let title = self.title else {
                return
            }
            subtitleLabel.text = title
            subtitleLabel.font = UIFont.systemFont(ofSize: 20)
            subtitleLabel.textColor = OshidoriColor.dark
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
