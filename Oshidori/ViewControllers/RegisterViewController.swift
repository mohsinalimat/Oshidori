//
//  RegisterViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/3/31.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    // 書き方の省略のため
    let user = User.shared
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var moveLoginPageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        if let credential = getCredential() {
            user.create(credential: credential)
            user.login(credential: credential)
        }
        if user.isLogin() {
            moveUserRegistPage()
        } else {
            self.alert("エラー", "メールアドレスかパスワードが間違っているようです😓", nil)
        }
    }
    
    @IBAction func didTapMoveLoginPageButton(_ sender: Any) {
        moveLoginPage()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
