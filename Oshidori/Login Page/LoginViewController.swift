//
//  LoginViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/3/30.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import PKHUD
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // 書き方の省略のため
    let user = User.shared

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user.delegate = self
        emailField.becomeFirstResponder()
        signInButton.layer.cornerRadius = 8.0
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func didTapSignInButton(_ sender: Any) {
        if let credential = getCredential() {
            HUD.show(.progress)
            user.login(credential: credential, completion: {[weak self] in
                guard let self = self else {
                    return
                }

                if self.user.isLogin() {
                    self.moveMessagePage()
                } else {
                    self.alert("エラー", "メールアドレスかパスワードが間違っているようです😓", nil)
                }
                HUD.hide()
            })
        }
         //デバッグ用
         // self.moveMessagePage()
    }
    
    func getCredential() -> Credential? {
        guard let email = emailField.text else {
            self.alert("エラー","メールアドレスを入力してください", nil)
            return nil
        }
        guard let password = passwordField.text else {
            self.alert("エラー", "パスワードを入力してください", nil)
            return nil
        }
        return Credential(email: email, password: password)
    }
    
    
}

extension LoginViewController: UserDelegate {
    // 作成後の処理
    func didCreate(error: Error?) {
        guard let err = error else {
            return
        }
        if let errCode = AuthErrorCode(rawValue: err._code) {
            switch errCode {
            case .invalidEmail:
                alert("エラー", "メールアドレスの形式を確認してください。", nil)
            case .emailAlreadyInUse:
                alert("エラー", "このメールアドレスはすでに使われています。", nil)
            case .weakPassword:
                alert("エラー", "パスワードは英数字6文字以上で入力してください。", nil)
            default:
                alert("エラー", "エラーが起きました🙇‍♂️　\nしばらくしてから再度お試しください。", nil)
            }
        }
    }
    
    // ログイン後の処理
    func didLogin(error: Error?) {
        guard let err = error else {
            return
        }
        if let errCode = AuthErrorCode(rawValue: err._code) {
            switch errCode {
            case .invalidEmail:
                alert("エラー", "メールアドレスの形式を確認してください。", nil)
            case .wrongPassword:
                alert("エラー", "パスワードが間違っています。", nil)
            case .weakPassword:
                alert("エラー", "パスワードは英数字6文字以上で入力してください。", nil)
            default:
                alert("エラー", "エラーが起きました🙇‍♂️　\nしばらくしてから再度お試しください。", nil)
            }
        }
    }
}
