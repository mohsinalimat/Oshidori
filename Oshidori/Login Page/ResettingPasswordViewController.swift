//
//  ResettingPasswordViewController.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/9.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResettingPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var alertTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.layer.cornerRadius = 8.0
        sendButton.backgroundColor = OshidoriColor.primary
        alertTextView.font = .systemFont(ofSize: 12)

    }
    
    @IBAction func didTapSendButton(_ sender: Any) {
        guard let email = emailField.text else {
            alert("エラー", "メールアドレスを入力してください。", nil)
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            guard let err = error else {
                self.alert("完了", "パスワード再設定のメールを送信しました。メールを確認し、再設定してください。", {
                    self.moveSelectRegisterOrLoginPage()
                })
                return
            }
            if let errCode = AuthErrorCode(rawValue: err._code) {
                switch errCode {
                case .invalidEmail:
                    self.alert("エラー", "メールアドレスの形式を確認してください。", nil)
                case .missingEmail:
                    self.alert("エラー", "メールアドレスが無効です。", nil)
                default:
                    self.alert("エラー", "エラーが発生しました🙇‍♂️。", nil)
                }
            }
        }
    }
    
}
