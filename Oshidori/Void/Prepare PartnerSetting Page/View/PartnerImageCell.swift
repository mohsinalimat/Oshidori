//
//  PartnerImageCell.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/6.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Nuke

class PartnerImageCell: UITableViewCell {

    @IBOutlet weak var partnerImageView: UIImageView!
    
    var imageUrl: String? {
        didSet {
            var url: URL?
            guard let strUrl = imageUrl else {
                return
            }
            url = URL(string: strUrl)
            if let url = url {
                Nuke.loadImage(with: url, into: partnerImageView)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        partnerImageView.layer.cornerRadius = partnerImageView.bounds.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
