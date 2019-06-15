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
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var checkBox: CheckBox!
    
    var isReadTermOfService = false {
        didSet {
            if isReadTermOfService {
                trueLayout()
            }
        }
    }
    
    @IBAction func termOfServiceButtonTapped(_ sender: Any) {
        let VC = TermOfServiceViewController.instantiate()
        VC.delegate = self
        present(VC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkBox.delegate = self
        // プッシュ通知の許諾ダイアログを出したいタイミングで呼んであげる. 必ずしもここじゃなくても良い
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in
            //debugPrint("push permission finished")
        }
        // 自動ログインの機能
        if User.shared.isLogin() {
            moveMessagePage()
        }
        
        if isReadTermOfService {
            isEnableCreateButtonTrue()
            trueLayout()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        moveUserCreateButton.backgroundColor = OshidoriColor.primary
        moveUserCreateButton.layer.cornerRadius = 8
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        isEnableCreateButtonTrue()
        falseLayout()
    }
    
    @IBAction func didTopMoveUserCreateButton(_ sender: Any) {
        moveUserCreatePage()
    }
    
    @IBAction func didTopMoveLoginButton(_ sender: Any) {
        moveLoginPage()
    }
    
    @IBAction func checkBoxTapped(_ sender: UIButton) {
    }
    
    @IBAction func agreeButtonTapped(_ sender: UIButton) {
        checkBox.buttonClicked(sender: checkBox)
    }
    
    func isEnableCreateButtonTrue() {
        if checkBox.isChecked {
            moveUserCreateButton.isEnabled = true
            moveUserCreateButton.alpha = 1.0
        } else {
            moveUserCreateButton.isEnabled = false
            moveUserCreateButton.alpha = 0.5
        }
    }
}

extension SelectRegisterOrLoginViewController: CheckBoxDelegate {
    func tapped() {
        isEnableCreateButtonTrue()
    }
}

extension SelectRegisterOrLoginViewController: TermOfServiceViewControllerDelegate {
    func confirmBackButton() {
        isReadTermOfService = true
    }
    
    func falseLayout() {
        checkBox.isEnabled = false
        agreeButton.isEnabled = false
        checkBox.alpha = 0.5
        agreeButton.alpha = 0.5
    }
    
    func trueLayout() {
        checkBox.isEnabled = true
        agreeButton.isEnabled = true
        checkBox.alpha = 1
        agreeButton.alpha = 1
    }
    
}
