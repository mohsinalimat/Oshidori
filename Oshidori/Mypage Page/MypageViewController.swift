//
//  MypageViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/29.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class MypageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var mypageTableView: UITableView!
    
    let settingTitleArray:[String] = ["パートナー設定", "ユーザー情報", "このアプリについて", "ログアウト"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mypageTableView.delegate = self
        mypageTableView.dataSource = self
        initialSettingForCell()
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
            return ""
            
        case 1:
            return "お手紙"
            
        case 2:
            return "設定"
            
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyImageAndNameCell", for: indexPath) as! MyImageAndNameTableViewCell
            cell.setUserImage()
            
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageReportCell", for: indexPath)
            return cell

        case 2:
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1,
                                       reuseIdentifier: settingTitleArray[indexPath.row])
            cell.textLabel?.text = settingTitleArray[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            return cell

        default:
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                                       reuseIdentifier: "")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 2 else {
            return
        }
        //     let settingTitleArray:[String] = ["パートナー設定", "ユーザー情報", "このアプリについて"]
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
