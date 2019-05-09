//
//  PartnerSettingViewController.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/7.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class PartnerSettingViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var alertTextView: UITextView!
    
    var partnerFlag :Bool?
    var partnerName :String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setting()
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        if partnerFlag == false {
            moveQRcodePage()
        } else {
            alertSelect("本当に解除しますか？", "※パートナーを解除すると全てのデータが削除されてしまいます。 \n※データの修復はできませんので、解除は慎重にお願いいたします。 \n※ログイン情報は残ります。") {
                let userService = UserInfoService()
                userService.deleteUserInfo(completion: {
                    self.alert("完了", "削除が完了しました！", {
                        User.shared.logout()
                        self.moveSelectRegisterOrLoginPage()
                    })
                })
            }
        }
        
    }
}

extension PartnerSettingViewController {
    func setting() {
        settingButton.layer.cornerRadius = 8.0
        
        guard let flag = partnerFlag else {
            return
        }
        if flag {
            settingButton.setTitle("解除する", for: .normal)
            settingButton.backgroundColor = OshidoriColor.dark
            settingButton.tintColor = OshidoriColor.background
            nameLabel.text = partnerName
            alertTextView.text = "※パートナーを解除すると全てのデータが削除されてしまいます。　\n※データの修復はできませんので、解除は慎重にお願いいたします。"
            
        } else {
            settingButton.setTitle("パートナーを紐づける", for: .normal)
            settingButton.backgroundColor = OshidoriColor.primary
            settingButton.tintColor = OshidoriColor.background
            nameLabel.text = "未設定"
            alertTextView.text = ""
        }
    }
}
