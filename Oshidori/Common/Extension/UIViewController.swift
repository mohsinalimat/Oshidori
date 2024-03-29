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
            if let closedHandler = closedHandler {
                closedHandler()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertSelect(_ title: String, _ message: String, _ closedHandler: (()->Void)?) {
        let alert = UIAlertController(title:title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "いいえ", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            
        }))
        alert.addAction(UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
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
    
    func moveSelectRegisterOrLoginPage() {
        let storyboard = UIStoryboard(name: "SelectRegisterOrLogin", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SelectRegisterOrLoginStoryboard")
        self.present(viewController, animated: true, completion: nil)
    }
    
    func moveUserCreatePage() {
        let VC = UINavigationController(rootViewController: RegistAuthUserViewController.instantiate())
        present(VC, animated: true, completion: nil)
    }
    
    func moveLoginPage() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "LoginStoryboard")
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func moveMessagePage() {
        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TabbarStoryboard")
        self.present(viewController, animated: true, completion: nil)
    }
    
    func moveQRcodePage() {
        let storyboard = UIStoryboard(name: "ShowQRcode", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "QRcodeStoryboard")
        VC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func moveUserEditPage() {
        let storyboard = UIStoryboard(name: "EditUserInfo", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "EditUserInfoStoryboard")
        // TODO: タブバー が出ちゃう
        VC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func moveUserRegistPage() {
        let storyboard = UIStoryboard(name: "RegistUserInfo", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "RegistUserInfoStoryboard")
        self.present(VC, animated: true, completion: nil)
    }
    
    func convertDateToString(timestampDate: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let stringDate = dateFormatter.string(from: timestampDate as Date)
        return stringDate
    }
}
