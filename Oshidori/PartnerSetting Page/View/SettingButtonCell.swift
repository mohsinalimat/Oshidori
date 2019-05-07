//
//  SettingButtonCell.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/7.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class SettingButtonCell: UITableViewCell {

    @IBOutlet weak var settingButton: UIButton!
    
    var cancelTitle: String? {
        didSet {
            settingButton.setTitle(cancelTitle, for: .normal)
            settingButton.backgroundColor = OshidoriColor.dark
            settingButton.tintColor = OshidoriColor.background
        }
    }
    
    var makeTitle: String? {
        didSet {
            settingButton.setTitle(makeTitle, for: .normal)
            settingButton.backgroundColor = OshidoriColor.primary
            settingButton.tintColor = OshidoriColor.background
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settingButton.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        if let _ = cancelTitle{
//            alertSelect("本当に解除しますか？", "※パートナーを解除すると全てのデータが削除されてしまいます。※データの修復はできませんので、解除は慎重にお願いいたします。") {
//                let userService = UserInfoService()
//                userService.deleteUserInfo(completion: {
//                    User.shared.logout()
//                    self.moveSelectRegisterOrLoginPage()
//                })
//            }
//        }
//        if let _ = makeTitle {
//            moveQRcodePage()
        }
    }
}
