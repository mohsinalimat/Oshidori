//
//  LoginViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/3/30.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UserDelegate {
    
    // 書き方の省略のため
    let user = User.shared

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if user.isLogin() {
            moveMessagePage()
            user.getUid()
        }
    }
    
    @IBAction func didTapSignInButton(_ sender: Any) {
        if let credential = getCredential() {
            user.login(credential: credential, completion: {[weak self] in
                guard let self = self else {
                    return
                }
                
                if self.user.isLogin() {
                    self.moveMessagePage()
                } else {
                    self.alert("エラー", "メールアドレスかパスワードが間違っているようです😓", nil)
                }
                
            })
        }
        
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        moveUserCreatePage()
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
    
    // 作成後の処理
    func didCreate(error: Error?) {
        if let error = error {
            self.alert("エラー", error.localizedDescription, nil)
            return
        }
    }
    
    // ログイン後の処理
    func didLogin(error: Error?) {
        if let error = error {
            self.alert("エラー", error.localizedDescription, nil)
            return
        }
    }
}
