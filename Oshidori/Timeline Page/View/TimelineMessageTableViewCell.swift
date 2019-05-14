//
//  TimelineMessageTableViewCellTableViewCell.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/11.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

protocol TimelineMessageTableViewCellDelegate: class {
    func shareButtonTapped(index: Int)
}

class TimelineMessageTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var sendDateLabel: UILabel!
    
    @IBOutlet weak var contentTypeLabel: UILabel!
    
    @IBOutlet weak var courageView: UIView!
    @IBOutlet weak var supportView: UIView!
    
    @IBOutlet weak var courageButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    
    @IBOutlet weak var courageCountLabel: UILabel!
    @IBOutlet weak var supportCountLabel: UILabel!
    
    @IBOutlet weak var courageTextLabel: UILabel!
    @IBOutlet weak var supportTextLabel: UILabel!
    
    @IBOutlet weak var courageImageView: UIImageView!
    @IBOutlet weak var supportImageView: UIImageView!
    
    var messageId: String?
    var uid: String?
    
    var isCourageTapped = false
    var isSupportTapped = false
    
    var delegate: TimelineMessageTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isCourageTapped {
            changeLayerForViewAfterTapped(courageView)
        } else {
            changeLayerForViewBeforeTap(courageView)
        }
        if isSupportTapped {
            changeLayerForViewAfterTapped(supportView)
        } else {
            changeLayerForViewBeforeTap(supportView)
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if isCourageTapped {
            changeLayerForViewAfterTapped(courageView)
        } else {
            changeLayerForViewBeforeTap(courageView)
        }
        if isSupportTapped {
            changeLayerForViewAfterTapped(supportView)
        } else {
            changeLayerForViewBeforeTap(supportView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if isCourageTapped {
            changeLayerForViewAfterTapped(courageView)
        } else {
            changeLayerForViewBeforeTap(courageView)
        }
        if isSupportTapped {
            changeLayerForViewAfterTapped(supportView)
        } else {
            changeLayerForViewBeforeTap(supportView)
        }
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        delegate?.shareButtonTapped(index: self.tag)
    }
    
    
    @IBAction func didTapCourageButton(_ sender: Any) {
        changeLayerForViewAfterTapped(courageView)
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
        changeLayerForViewAfterTapped(supportView)
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
    
    func changeLayerForViewBeforeTap(_ view: UIView) {
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.backgroundColor = OshidoriColor.background
        if view == courageView {
            courageImageView.image = UIImage(named: "Courage_before")
            courageTextLabel.textColor = .lightGray
            courageCountLabel.textColor = .lightGray
            courageButton.isEnabled = true
        }
        if view == supportView{
            supportImageView.image = UIImage(named: "Support_before")
            supportTextLabel.textColor = .lightGray
            supportCountLabel.textColor = .lightGray
            supportButton.isEnabled = true
        }
        
    }
    
    func changeLayerForViewAfterTapped(_ view: UIView) {
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = OshidoriColor.primary.cgColor
        view.backgroundColor = OshidoriColor.primary
        if view == courageView {
            courageImageView.image = UIImage(named: "Courage_after")
            courageTextLabel.textColor = .white
            courageCountLabel.textColor = .white
            courageButton.isEnabled = false
            // TODO: ここに＋1するものを追加すればOK
        }
        if view == supportView{
            supportImageView.image = UIImage(named: "Support_after")
            supportTextLabel.textColor = .white
            supportCountLabel.textColor = .white
            supportButton.isEnabled = false
        }
    }
    
    func setContentLabel(content: String) {
        contentLabel.text = content
    }
    
    func setSendDataLabel(sendDate: String) {
        sendDateLabel.text = sendDate
    }
    
    func setContentType(contentType: String) {
        switch contentType {
        case "ありがとう":
            contentTypeLabel.text = "ありがとう"
            contentTypeLabel.textColor = OshidoriColor.thanks
        case "ごめんね":
            contentTypeLabel.text = "ごめんね"
            contentTypeLabel.textColor = OshidoriColor.sorry
        case "あのね":
            contentTypeLabel.text = "あのね"
            contentTypeLabel.textColor = OshidoriColor.anone
        default:
            contentTypeLabel.text = "ありがとう"
            contentTypeLabel.textColor = OshidoriColor.thanks
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
    
    func setIsCourageTapped(isTapped :Bool) {
        self.isCourageTapped = isTapped
    }
    
    func setIsSupportTapped(isTapped :Bool) {
        self.isSupportTapped = isTapped
    }
    
}
