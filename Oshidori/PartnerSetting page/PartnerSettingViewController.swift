//
//  PartnerSettingViewController.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/7.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Nuke

class PartnerSettingViewController: UIViewController {
    
    @IBOutlet weak var partnerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var AlertTextView: UITextView!
    
    var partnerFlag :Bool? {
        didSet {
            guard let flag = partnerFlag else {
                return
            }
            if flag {
                settingButton.setTitle("解除する", for: .normal)
                settingButton.backgroundColor = OshidoriColor.dark
                settingButton.tintColor = OshidoriColor.background
            } else {
                settingButton.setTitle("パートナーを紐づける", for: .normal)
                settingButton.backgroundColor = OshidoriColor.primary
                settingButton.tintColor = OshidoriColor.background
            }
        }
    }

    var partnerName :String?  {
        didSet {
            nameLabel.text = partnerName
        }
    }
    
    var partnerImageUrl :String? {
        didSet {
            var url: URL?
            guard let strUrl = partnerImageUrl else {
                return
            }
            url = URL(string: strUrl)
            if let url = url {
                Nuke.loadImage(with: url, into: partnerImageView)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        if partnerFlag == false {
            moveQRcodePage()
        } else {
            alertSelect("本当に解除しますか？", "※パートナーを解除すると全てのデータが削除されてしまいます。※データの修復はできませんので、解除は慎重にお願いいたします。") {
                let userService = UserInfoService()
                userService.deleteUserInfo(completion: {
                    User.shared.logout()
                    self.moveSelectRegisterOrLoginPage()
                })
            }
        }
        
    }
}

extension PartnerSettingViewController {
    func setting() {
        partnerImageView.layer.cornerRadius = partnerImageView.bounds.width / 2
        
    }
}
