//
//  TimelineMessageTableViewCellTableViewCell.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/11.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class TimelineMessageTableViewCellTableViewCell: UITableViewCell {

    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    @IBOutlet weak var contentTypeImageByOshidori: UIImageView!
    @IBOutlet weak var contentTypeImageByMessage: UIImageView!
    
    @IBOutlet weak var courageView: UIView!
    @IBOutlet weak var supportView: UIView!
    
    @IBOutlet weak var courageButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        changeLayerForView(courageView)
        changeLayerForView(supportView)
    }
    
    @IBAction func didTapCourageButton(_ sender: Any) {
        courageView.backgroundColor = OshidoriColor.primary
        courageButton.isEnabled = false
        print(courageButton.tag)
        print("🌞")
        // TODO:カウントを増やす処理
        
        
    }
    
    @IBAction func didTapSupportButton(_ sender: Any) {
        supportView.backgroundColor = OshidoriColor.primary
        supportButton.isEnabled = false
        print(supportButton.tag)
        print("👿")
        // TODO:カウントを増やす処理
    }
    
    func changeLayerForView(_ view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        // TODO: ボーダーの色いるかな？
        view.layer.borderColor = OshidoriColor.background.cgColor
        view.backgroundColor = OshidoriColor.light
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    func setContentLabel(content: String) {
        contentLabel.text = content
    }
    
    func setDataLabel(date: String) {
        dateLabel.text = date
    }
    
    
    
    func setContentTypeImage(contentType: String) {
        switch contentType {
        case "ありがとう":
            contentTypeImageByOshidori.image = UIImage(named: "Oshidori_thanks")
            contentTypeImageByMessage.image  = UIImage(named: "Message_thanks")
        case "ごめんね":
            contentTypeImageByOshidori.image = UIImage(named: "Oshidori_sorry")
            contentTypeImageByMessage.image  = UIImage(named: "Message_sorry")
        case "あのね":
            contentTypeImageByOshidori.image = UIImage(named: "Oshidori_anone")
            contentTypeImageByMessage.image  = UIImage(named: "Message_anone")
        default:
            contentTypeImageByOshidori.image = UIImage(named: "Oshidori_normal")
            contentTypeImageByMessage.image  = UIImage(named: "Message_thanks")
        }
    }
    
}
