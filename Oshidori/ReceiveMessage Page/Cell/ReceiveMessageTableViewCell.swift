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
    @IBOutlet weak var contentTypeLabel: UILabel!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentTypeImage: UIImageView!
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var noticeNotReadLabel: UILabel!
    
    var isNotRead = false
    
    let shadowView = UIView()
    let innerLayer = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = OshidoriColor.background
        addShadowForView(messageView)
        changeLayerForLabel(noticeNotReadLabel)
        if !isNotRead {
            noticeNotReadLabel.isHidden = true
        } else {
            noticeNotReadLabel.isHidden = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        changeLayerForView(messageView)
        if !isNotRead {
            noticeNotReadLabel.isHidden = true
        } else {
            noticeNotReadLabel.isHidden = false
        }
    }
    
    override func prepareForReuse() {
        super .prepareForReuse()
        if !isNotRead {
            noticeNotReadLabel.isHidden = true
        } else {
            noticeNotReadLabel.isHidden = false
        }
    }
    
    func changeLayerForLabel(_ label: UILabel) {
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.backgroundColor = OshidoriColor.primary
        label.textColor = .white
    }
    
    func changeLayerForView(_ view: UIView) {
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
    }
    
    func addShadowForView(_ view:UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0, height: 5); // 下向きの影
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.3
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    
    func setContentLabel(content: String) {
        contentLabel.text = content
    }
    
    func setSentDataLabel(date: String) {
        dateLabel.text = date
    }
    
    func setNameLabel(name: String) {
        nameLabel.text = name + "より"
    }
    
    func setContentTypeImage(contentType: String) {
        switch contentType {
        case "ありがとう":
            contentTypeImage.image = UIImage(named: "Oshidori_thanks")
            contentTypeLabel.text = "ありがとうのお手紙"
            contentTypeLabel.textColor = OshidoriColor.thanks
        case "ごめんね":
            contentTypeImage.image = UIImage(named: "Oshidori_sorry")
            contentTypeLabel.text = "ごめんねのお手紙"
            contentTypeLabel.textColor = OshidoriColor.sorry
        case "あのね":
            contentTypeImage.image = UIImage(named: "Oshidori_anone")
            contentTypeLabel.text = "あのねのお手紙"
            contentTypeLabel.textColor = OshidoriColor.anone
        default:
            contentTypeImage.image = UIImage(named: "Oshidori_thanks")
            contentTypeLabel.text = "ありがとうのお手紙"
            contentTypeLabel.textColor = OshidoriColor.thanks
        }
    }

    
}
