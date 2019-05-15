//
//  SendEmailViewController.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/15.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class SendEmailViewController: UIViewController {

    @IBOutlet weak private var emailField: UITextField!
    @IBOutlet weak private var sendEmailButton: UIButton!
    @IBOutlet weak private var alertTextView: UITextView!
    
    let db = Firestore.firestore()
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendEmailButton.backgroundColor = OshidoriColor.primary
        sendEmailButton.setTitleColor(.white, for: .normal)
        sendEmailButton.setTitle("送信", for: .normal)
        sendEmailButton.layer.cornerRadius = 8.0
        alertTextView.font = .systemFont(ofSize: 12)
        setDelegate()
    }
    
    @IBAction func didTappedSendEmailButton(_ sender: Any) {
        guard let email = emailField.text else {
            return
        }
        guard isValidEmail(testStr: email) else {
            alert("エラー", "正しいメールアドレスを入力してください。", nil)
            return
        }
        let reference = db.collection("sendEmail")
        guard let token = userDefault.object(forKey: "FCMToken") else {
            debugPrint("token is null 👿")
            return
        }
        reference.addDocument(data:["email": email, "FCMToken": token,] ) { (error) in
            if let err = error  {
                debugPrint(err.localizedDescription)
                self.alert("エラー", "そのメールアドレスのユーザは存在しません", nil)
                return
            }
            //self.alert("確認", "メールアドレスを確認しています。\nしばらくお待ちください。", nil)
            HUD.show(.progress)
        }
    }
    
}

extension SendEmailViewController {
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func settingPartner(partnerId: String) {
        HUD.show(.progress)
        // TODO: partnerIdが存在するかどうかを確認しなきゃいけない
        PartnerSettingService.shared.isExistPartner(partnerId: partnerId) { (result, partnerName) in
            HUD.hide()
            if result == true {
                if let name = partnerName {
                    self.alertSelect("確認", "\(name)さんをパートナーとして紐付けますか？", {
                        HUD.show(.progress)
                        // 読み取り終了
                        // ユーザ情報をsetする
                        PartnerSettingService.shared.save(partnerId)
                        
                    })
                }
                
            } else {
                self.alert("エラー", "ユーザが存在しません！正しいQRコードを読み込んでください！", nil)
            }
        }
    }
}

extension SendEmailViewController: PartnerSettingServiceDelegateDelegate {
    func gotInfo() {
        HUD.hide()
        PartnerSettingService.shared.updateUserInfo()
        HUD.show(.progress)
    }
    
    func updated() {
        HUD.hide()
        moveMessagePage()
        
    }
    
    func setDelegate() {
        PartnerSettingService.shared.delegate = self
    }
}

