//
//  SelectRegisterOrLoginViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/22.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import UserNotifications

class SelectRegisterOrLoginViewController: UIViewController {

    @IBOutlet weak var moveUserCreateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // プッシュ通知の許諾ダイアログを出したいタイミングで呼んであげる. 必ずしもここじゃなくても良い
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in
            //debugPrint("push permission finished")
        }
        // 自動ログインの機能
        if User.shared.isLogin() {
            moveMessagePage()
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        moveUserCreateButton.backgroundColor = OshidoriColor.primary
        moveUserCreateButton.layer.cornerRadius = 8
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func didTopMoveUserCreateButton(_ sender: Any) {
        let VC = TermOfServiceViewController.instantiate()
        present(VC, animated: true, completion: nil)
    }
    
    @IBAction func didTopMoveLoginButton(_ sender: Any) {
        moveLoginPage()
    }
    

}
