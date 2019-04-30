//
//  AuthRegisterViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/3/31.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import PKHUD

class RegistAuthUserViewController: UIViewController {

    // 書き方の省略のため
    let user = User.shared
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        registButton.backgroundColor = OshidoriColor.primary
        registButton.layer.cornerRadius = 8.0
        emailField.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        if let credential = getCredential() {
            HUD.show(.progress)
            user.create(credential: credential, completion: { [weak self] in
                guard let self = self else {
                    return
                }
                
                // TODO: メールを送って、確認することができる！！！
//                self.user.verificate(credential: credential, completion: {
//                    //
//                })
                
                self.user.login(credential: credential, completion: {
                    // TODO: login の後に、この処理を走らせたい。どうやっていいかわからない。。。
                    if self.user.isLogin() {
                        self.moveUserRegistPage()
                    } else {
                        self.alert("エラー", "メールアドレスかパスワードが間違っているようです😓", nil)
                    }
                    HUD.hide()
                })
            })
        }
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
