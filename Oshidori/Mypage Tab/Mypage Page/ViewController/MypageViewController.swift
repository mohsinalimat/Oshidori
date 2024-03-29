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
    
    var partnerFlag: Bool = false
    var partnerName: String = ""
    
    let settingTitleArray:[String] = ["パートナー設定", "このアプリについて", "ログアウト"]
    
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
        getInformation()
        mypageTableView.reloadData()
        mypageTableView.tableFooterView = UIView()
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
            return " "
            
        case 2:
            return " "
            
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyImageAndNameCell", for: indexPath) as! MyImageAndNameTableViewCell
            cell.delegate = self
            if let userInfo = mypageService.userInfo {
                cell.setUserImage(imageUrl: userInfo.imageUrl)
                cell.setUserName(name: userInfo.name)
                if userInfo.partnerId == "" {
                    partnerFlag = false
                } else {
                    partnerFlag = true
                    if let roomInfo = mypageService.roomInfo {
                        partnerName = roomInfo.partnerName
                    } else {
                        partnerName = "取得に失敗しました"
                    }
                }
            }
            cell.selectionStyle = .none
            
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageReportCell", for: indexPath) as! MessageReportTableViewCell
           
            cell.setCourageCountLabel(courageCount: mypageService.getCourageCount())
            cell.setSupportCountLabel(supportCount: mypageService.getSupportCount())
            cell.setMessageCountLabel(messageCount: mypageService.getMessageCount())
            cell.selectionStyle = .none
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
            movePartnerInfoPage()
        case 1:
            moveAppDescriptionPage()
        case 2:
            alertSelect("ログアウト", "本当にログアウトしますか？") {
                // TODO :最終的にONにする
                User.shared.logout()
                self.moveSelectRegisterOrLoginPage()
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 100
        }
        return 0
    }
}

extension MypageViewController {
    func movePartnerInfoPage() {
        let storyboard = UIStoryboard(name: "PartnerSettingViewController", bundle: nil)
        guard let VC = storyboard.instantiateViewController(withIdentifier: "PartnerSettingViewController") as? PartnerSettingViewController else {
            return
        }
        VC.partnerFlag = partnerFlag
        VC.partnerName = partnerName
        VC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func moveAppDescriptionPage() {
        let storyboard = UIStoryboard(name: "AppDescriptionViewController", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "AppDescriptionViewController")
        VC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(VC, animated: true)
    }
}

extension MypageViewController {
    
    func getInformation() {
        getUserMessageInfo()
        getUserAndRoomInfo()
    }
    
    func getUserMessageInfo() {
        guard let uid = User.shared.getUid() else {
            return
        }
        mypageService.getUserMessageInfo(uid: uid)
    }
    
    func getUserAndRoomInfo() {
        guard let _ = User.shared.getUid() else {
            return
        }
        mypageService.getUserAndRoomInfo()
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

extension MypageViewController: MyImageAndNameTableViewCellDelegate {
    func tapped() {
        moveUserEditPage()
    }
}
