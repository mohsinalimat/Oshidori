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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentTypeImage: UIImageView!
    @IBOutlet weak var messageView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        changeLayerForView(messageView)
    }
    
    func changeLayerForView(_ view: UIView) {
        view.layer.cornerRadius = 15
        view.backgroundColor = OshidoriColor.light
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
    }

    
    func setContentLabel(content: String) {
        contentLabel.text = content
    }
    
    func setDataLabel(date: String) {
        dateLabel.text = date
    }
    
    func setNameLabel(name: String) {
        nameLabel.text = name + "より"
    }
    
    func setContentTypeImage(contentType: String) {
        switch contentType {
        case "ありがとう":
            contentTypeImage.image = UIImage(named: "Oshidori_thanks")
        case "ごめんね":
            contentTypeImage.image = UIImage(named: "Oshidori_sorry")
        case "あのね":
            contentTypeImage.image = UIImage(named: "Oshidori_anone")
        default:
            contentTypeImage.image = UIImage(named: "Oshidori_normal")
        }
    }

    
}
