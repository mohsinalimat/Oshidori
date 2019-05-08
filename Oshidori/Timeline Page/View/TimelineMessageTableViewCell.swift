//
//  TimelineMessageTableViewCellTableViewCell.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/11.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class TimelineMessageTableViewCell: UITableViewCell {

    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var sendDateLabel: UILabel!
    
    @IBOutlet weak var contentTypeImageByOshidori: UIImageView!
    @IBOutlet weak var contentTypeImageByMessage: UIImageView!
    
    @IBOutlet weak var courageView: UIView!
    @IBOutlet weak var supportView: UIView!
    
    @IBOutlet weak var courageButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    
    @IBOutlet weak var courageCountLabel: UILabel!
    @IBOutlet weak var supportCountLabel: UILabel!
    
    var messageId: String?
    var uid: String?
    
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
        
        guard let strCourageCount = courageCountLabel.text else {
            return
        }
        if let intCourageCount = Int(strCourageCount) {
            let count = intCourageCount + 1
            courageCountLabel.text = String(count)
        }
        // messageIdを持っておけば探せるのでは？
        guard let messageId = messageId, let uid = uid else {
            return
        }
        TimelineService.shared.updateCourageCountForMessage(messageId: messageId)
        TimelineService.shared.updateCourageCountForUser(uid: uid)
    }
    
    @IBAction func didTapSupportButton(_ sender: Any) {
        supportView.backgroundColor = OshidoriColor.primary
        supportButton.isEnabled = false
        
        guard let strSupportCount = supportCountLabel.text else {
            return
        }
        if let intSupportCount = Int(strSupportCount) {
            let count = intSupportCount + 1
            supportCountLabel.text = String(count)
        }
        guard let messageId = messageId, let uid = uid else {
            return
        }
        TimelineService.shared.updateSupportCountForMessage(messageId: messageId)
        TimelineService.shared.updateSupportCountForUser(uid: uid)
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
    
    func setSendDataLabel(sendDate: String) {
        sendDateLabel.text = sendDate
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
    
    func setSenderId(senderId uid: String) {
        self.uid = uid
    }
    
    func setCourageCountLabel(courageCount: Int) {
        courageCountLabel.text = String(courageCount)
    }
    
    func setSupportCountLabel(supportCount: Int) {
        supportCountLabel.text = String(supportCount)
    }
    
}
