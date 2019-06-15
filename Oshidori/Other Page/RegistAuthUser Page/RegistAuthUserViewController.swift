//
//  AuthRegisterViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/3/31.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import PKHUD
import FirebaseAuth

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
        
        User.shared.delegate = self

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
                    if self.user.isLogin() {
                        self.moveUserRegistPage()
                    } else {
                        
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

extension RegistAuthUserViewController: UserDelegate {
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
    
    func didLogin(error: Error?) {
        guard let err = error else {
            return
        }
        debugPrint(err.localizedDescription)
        if let errCode = AuthErrorCode(rawValue: err._code) {
            switch errCode {
            case .invalidEmail:
                alert("エラー", "メールアドレスの形式を確認してください。", nil)
            case .wrongPassword:
                alert("エラー", "パスワードが間違っています。", nil)
            default:
                alert("エラー", "エラーが起きました🙇‍♂️　\nしばらくしてから再度お試しください。", nil)
            }
        }
    }
    
    
}
