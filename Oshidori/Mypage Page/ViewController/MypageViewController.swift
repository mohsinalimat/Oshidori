//
//  MypageViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/29.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class MypageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let mypageService = MypageService.shared
    
    @IBOutlet weak var mypageTableView: UITableView!
    
    let settingTitleArray:[String] = ["パートナー設定", "ユーザー情報", "このアプリについて", "ログアウト"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mypageTableView.delegate = self
        mypageTableView.dataSource = self
        mypageService.delegate = self
        initialSettingForCell()
        getInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        // mypageTableView.reloadData()
    }

}

extension MypageViewController {
    
    func initialSettingForCell() {
        mypageTableView.register (UINib(nibName: "MessageReportTableViewCell", bundle: nil),forCellReuseIdentifier:"MessageReportCell")
        mypageTableView.register (UINib(nibName: "MyImageAndNameTableViewCell", bundle: nil),forCellReuseIdentifier:"MyImageAndNameCell")
        
        // セルの高さを内容によって可変にする
        mypageTableView.estimatedRowHeight = 50 //予想のセルの高さ //入れないとワーニングが出る
        mypageTableView.rowHeight = UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return settingTitleArray.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
            
        case 1:
            return "お手紙"
            
        case 2:
            return "設定"
            
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyImageAndNameCell", for: indexPath) as! MyImageAndNameTableViewCell
            if let userInfo = MypageService.shared.userInfo {
                cell.setUserImage(imageUrl: userInfo.imageUrl)
                cell.setUserName(name: userInfo.name)
            }
            
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageReportCell", for: indexPath) as! MessageReportTableViewCell
           
            cell.setCourageCountLabel(courageCount: mypageService.getCourageCount())
            cell.setSupportCountLabel(supportCount: mypageService.getSupportCount())
            cell.setMessageCountLabel(messageCount: mypageService.getMessageCount())
            
            return cell

        case 2:
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1,
                                       reuseIdentifier: settingTitleArray[indexPath.row])
            cell.textLabel?.text = settingTitleArray[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            
            return cell

        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 色が変わらないようにする
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        guard indexPath.section == 2 else {
            return
        }
        switch indexPath.row {
        case 0:
            moveQRcodePage()
        case 1:
            moveUserEditPage()
        case 2:
            moveMessagePage()
        case 3:
            alertSelect("ログアウト", "本当にログアウトしますか？") {
                // TODO :最終的にONにする
                // User.shared.logout()
                self.moveSelectRegisterOrLoginPage()
            }
        default:
            break
        }
    }
}

extension MypageViewController {
    
    func getInformation() {
        getUserMessageInfo()
        getUserInfo()
    }
    
    func getUserMessageInfo() {
        guard let uid = User.shared.getUid() else {
            return
        }
        mypageService.getUserMessageInfo(uid: uid)
    }
    
    func getUserInfo() {
        guard let uid = User.shared.getUid() else {
            return
        }
        mypageService.getUserInfo()
    }
}

extension MypageViewController: MypageServiceDelegate {
    func gotUserInfo() {
        mypageTableView.reloadData()
    }
    
    
    func gotUserMessageInfo() {
        mypageTableView.reloadData()
    }
    
    func loaded() {
        
    }
}
