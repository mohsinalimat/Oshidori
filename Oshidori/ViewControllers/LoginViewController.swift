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
    
    // キーボード以外をタップした時に、キーボードを消す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func didTapSignInButton(_ sender: Any) {
        
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        if let credential = getCredential() {
            user.create(credential: credential)
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
    
    func didCreate(error: Error?) {
        
    }
    
    func didLogin(error: Error?) {
        
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
