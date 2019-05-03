//
//  UserEditViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/16.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Firebase
import PKHUD
import Eureka

class EditUserInfoViewController: FormViewController {

    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var userInformation: UserInformation!
    
    let editUserInfoService = EditUserInfoService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        editUserInfoService.loadUserInfo()
    }
}

extension EditUserInfoViewController: EditUserInfoServiceDelegate {
    
    func setDelegate() {
        editUserInfoService.delegate = self
    }
    
    func updated() {
        
    }
    
    func loaded() {
        form +++ Section("ユーザー")
            <<< LabelRow(){ row in
                row.title = "ニックネーム"
                row.value = editUserInfoService.editUserInfo?.name ?? "未設定"
                row.onCellSelection({ (LabelCell, LabelRow) in
                    guard let content = LabelRow.title else {
                        return
                    }
                    self.moveEditInformationPage(content)
                })
                row.cellUpdate({ (LabelCell, LabelRow) in
                    LabelCell.accessoryType = .disclosureIndicator
                })
            }
            <<< LabelRow(){ row in
                row.title = "誕生日"
                if let birthday = editUserInfoService.editUserInfo?.birthday {
                    let strBirthday = convertDateToString(timestampDate: birthday as NSDate)
                    row.value = strBirthday
                } else {
                    row.value = "未設定"
                }
                row.onCellSelection({ (LabelCell, LabelRow) in
                    guard let content = LabelRow.title else {
                        return
                    }
                    self.moveEditInformationPage(content)
                })
                row.cellUpdate({ (LabelCell, LabelRow) in
                    LabelCell.accessoryType = .disclosureIndicator
                })
            }
            <<< LabelRow(){ row in
                row.title = "プロフィール写真"
                row.value = "未設定"
//                if let userPhoto = editUserInfoService.editUserInfo?.birthday {
//                    let strBirthday = convertDateToString(timestampDate: birthday as NSDate)
//                    row.value = strBirthday
//                } else {
//                    row.value = "未設定"
//                }
                
                row.onCellSelection({ (LabelCell, LabelRow) in
                    guard let content = LabelRow.title else {
                        return
                    }
                    self.moveEditInformationPage(content)
                })
                row.cellUpdate({ (LabelCell, LabelRow) in
                    LabelCell.accessoryType = .disclosureIndicator
                })
            }
            
            +++ Section("パートナー")
            <<< LabelRow(){ row in
                row.title = "ニックネーム"
                row.value = editUserInfoService.editUserInfo?.partnerName ?? "未設定"
                row.value = "ナッキー"
        }
    }
}

extension EditUserInfoViewController {
    
    func moveEditInformationPage(_ content: String) {
        let storyboard = UIStoryboard(name: "EditInformation", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "EditInformationStoryboard") as! EditInformationViewController
        VC.editContent = content
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
}
