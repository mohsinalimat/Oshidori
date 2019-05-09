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
    
    let shadowView = UIView()
    let innerLayer = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = OshidoriColor.background
        addShadowForView(messageView)
//        shadowView.backgroundColor = .white
//        shadowView.layer.shadowColor = UIColor.black.cgColor
//        shadowView.layer.shadowOpacity = 0.1
//        shadowView.layer.shadowRadius = 10
//        shadowView.layer.shadowOffset = CGSize(width: 5, height: 5)
//        messageView.insertSubview(shadowView, belowSubview: self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        changeLayerForView(messageView)
    }
    
    func changeLayerForView(_ view: UIView) {
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
//        view.layer.shadowOpacity = 0.1
//        view.layer.shadowRadius = 15
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func addShadowForView(_ view:UIView) {
        
//        let path = UIBezierPath(rect: CGRect(x: -5.0, y: -5.0, width: self.frame.size.width + 5.0, height: 5.0 ))
//        innerLayer.frame = messageView.frame
//        innerLayer.masksToBounds = true
//        innerLayer.shadowColor = UIColor.black.cgColor
//        innerLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
//        innerLayer.shadowOpacity = 0.5
//        innerLayer.shadowPath = path.cgPath
//        messageView.layer.addSublayer(innerLayer)
        
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
