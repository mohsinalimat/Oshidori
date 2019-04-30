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
    
    @IBOutlet weak var courageCountLabel: UILabel!
    @IBOutlet weak var supportCountLabel: UILabel!
    
    var messageId: String?
    
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
        
        // TODO:カウントを増やす処理
        guard let strCourageCount = courageCountLabel.text else {
            return
        }
        if let intCourageCount = Int(strCourageCount) {
            let count = intCourageCount + 1
            courageCountLabel.text = String(count)
        }
        // messageIdを持っておけば探せるのでは？
        guard let messageId = messageId else {
            debugPrint("👿messageIdを取り出せませんでした")
            return
        }
        TimelineService.shared.updateCourageCountForMessage(messageId: messageId)
        
    }
    
    @IBAction func didTapSupportButton(_ sender: Any) {
        supportView.backgroundColor = OshidoriColor.primary
        supportButton.isEnabled = false
        print(supportButton.tag)
        print("👿")
        // TODO:カウントを増やす処理
    }
    
    func changeLayerForView(_ view: UIView) {
        view.layer.cornerRadius = 8
        // view.layer.borderWidth = 1
        // TODO: ボーダーの色いるかな？
        //view.layer.borderColor = OshidoriColor.background.cgColor
        view.backgroundColor = OshidoriColor.light
//        view.layer.shadowOpacity = 0.1
//        view.layer.shadowRadius = 10
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 2, height: 2)
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
    
    func setMessageId(messageId: String) {
        self.messageId = messageId
    }
    
    func setCourageCountLabel(courageCount: Int) {
        courageCountLabel.text = String(courageCount)
    }
    
    func setSupportCountLabel(supportCount: Int) {
        supportCountLabel.text = String(supportCount)
    }
    
}
