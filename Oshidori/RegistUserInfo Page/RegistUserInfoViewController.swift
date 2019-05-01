//
//  UserInfoRegisterViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/16.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import PKHUD

class RegistUserInfoViewController: UIViewController, UITextFieldDelegate {
    
    
    // TODO: ここから離脱した人のことを考える。Authは登録したけど、Userは登録していない人

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var registButton: UIButton!
    
    let userInfoService = UserInfoService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.becomeFirstResponder()
        
        userInfoService.delegate = self
        nameField.delegate = self
        
        registButton.backgroundColor = OshidoriColor.primary
        registButton.layer.cornerRadius = 8.0
       
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        guard let name = nameField.text else {
            alert("error", "ニックネームか誕生日を入力してください!", nil)
            return
        }
        if name ==  "" {
            alert("error", "ニックネームを入力してください!", nil)
            return
        }
        let created = Date()
        // 初期のデータを保存するため、partnerIdとroomIdは"" で良い。
        // TODO: nil が怖いので要注意 すでにクラッシュしてる
        let userInfo = UserInformation(name: name, birthday: nil, partnerId: "", roomId: "", created: created)
        HUD.show(.progress)
        UserInfoService.shared.save(userInfo)
    }
    
}

extension RegistUserInfoViewController: UserInfoServiceDelegate {
    func saved() {
        HUD.hide()
        moveMessagePage()
    }
    
    func loaded() {
        
    }
}
