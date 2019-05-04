//
//  User.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/3/30.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import Firebase

// プロトコルとは、具体的な処理内容は書かず、クラスや構造体が実装するプロパティとメソッドを定義する機能
// UserDelegateには、以下のメソッドを必ずもたせたいため、定義
protocol UserDelegate: class {
    func didCreate(error: Error?)
    func didLogin(error: Error?)
}

class User {
    
    // シングルトン実装
    static let shared = User()
    
    // 現在ログインしているユーザの取得
    private var user: FirebaseAuth.User? {
        get {
            return Auth.auth().currentUser
        }
    }
    
    weak var delegate: UserDelegate?
    
    // ユーザ作成
    func create (credential: Credential, completion: @escaping () -> Void) {
        Auth.auth().createUser(withEmail: credential.email, password: credential.password) { (result, error) in
            if let error = error {
                // error をはかせる
                print ("👿")
                print (error.localizedDescription)
            } else {
                print("🌞ユーザー作成成功")
            }
            self.delegate?.didCreate(error: error)
            completion()
        }
        
    }
    
    // メール認証
    func verificate(credential: Credential, completion: @escaping () -> Void ){
        Auth.auth().currentUser?.sendEmailVerification()
    }
    
    func isCheckVelifyEmail() -> Bool {
        return Auth.auth().currentUser?.isEmailVerified ?? false
    }
    
    // ログイン
    func login (credential: Credential, completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: credential.email, password: credential.password) { (result, error) in
            if let error = error {
                print ("👿")
                print (error.localizedDescription)
            } else {
                print("🌞ログイン成功")
            }
            self.delegate?.didLogin(error: error)
            completion()
        }
    }
    
    // ログアウト
    func logout(){
        try! Auth.auth().signOut()
    }
    
    // ログインしているかどうか
    func isLogin () -> Bool {
        if user != nil {
            return true
        }
        return false
    }
    
    func getUid () -> String? {
        return user?.uid
    }

}


