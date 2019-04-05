//
//  UIViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/3/31.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
extension UIViewController {
    // UIViewControllerやUIViewControllerを継承するクラス下記の関数を使えるようにしている。
    func alert(_ title: String, _ message: String, _ closedHandler: (()->Void)?) {
        let alert = UIAlertController(title:title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            print("閉じる")
            if let closedHandler = closedHandler {
                closedHandler()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // open 別モジュールから呼び出せる。継承やオーバーライドが可能
    // デフォルトでは internalになる、overrideの宣言よりも強いアクセス修飾子になるため、openをつけなければいけない。
    // internal    モジュール内ならアクセスできる。 何も書かないとコレになる。（デフォルト）
    // キーボード以外をタップした時に、キーボードを消す
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func moveTestPage() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TestStoryboard")
        self.present(viewController, animated: true, completion: nil)
    }
    
    func moveUserCreatePage() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "UserCreateStoryboard")
        self.present(viewController, animated: true, completion: nil)
    }
    
    func moveLoginPage() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginStoryboard")
        self.present(viewController, animated: true, completion: nil)
    }
    func moveMessagePage() {
        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MessageStoryboard")
        self.present(viewController, animated: true, completion: nil)
    }
}
