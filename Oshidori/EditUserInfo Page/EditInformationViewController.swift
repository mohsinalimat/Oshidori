//
//  EditInformation.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/29.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Eureka
import ImageRow

class EditInformationViewController: FormViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var editContent:String?
    var birthday :Date?
    var nickName :String?
    
    let nickNameContent = "ニックネーム"
    let birthdayContent = "誕生日"
    let photoContent    = "プロフィール写真"

    var selectedImg = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let content = editContent else {
            moveUserEditPage()
            return
        }
        setEditContent(content)
    }
    
    
    func setEditContent(_ content : String) {
        switch content {
        case nickNameContent:
            form +++ Section("ニックネーム編集")
                <<< TextRow(){ row in
                    row.title = "ニックネーム"
                    row.placeholder = "入力してね！"
                    row.onChange({ (TextRow) in
                        self.nickName = TextRow.value
                    })
                    
            }
        case birthdayContent:
            form +++ Section("誕生日編集")
                <<< DateRow(){
                    $0.title = "誕生日"
                    $0.value = Date(timeIntervalSinceReferenceDate: 0)
                    $0.onChange({ (DateRow) in
                        self.birthday = DateRow.value
                    })
            }
        case photoContent:
            form +++ Section("プロフィール写真編集")
                <<< ImageRow(){
                    $0.title = "画像"
                    $0.sourceTypes = [.PhotoLibrary]
                    $0.clearAction = .no
                    $0.onChange { [unowned self] row in
                        if let value = row.value {
                            self.selectedImg = value
                        }
                    }
                    $0.cellUpdate { cell, row in
                        cell.accessoryView?.layer.cornerRadius = 17
                        cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
                    }
            }
            
        default:
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        guard let content = editContent else {
            return
        }
        
        switch content {
        case nickNameContent:
            guard let name = nickName else {
                alert("エラー", "値を変更してください", nil)
                return
            }
            // TODO: 保存する

        case birthdayContent:
            guard let birthday = birthday else {
                alert("エラー", "値を変更してください", nil)
                return
            }
            // TODO: 保存する

        case photoContent:
            guard let birthday = birthday else {
                alert("エラー", "値を変更してください", nil)
                return
            }
            // TODO: 保存する

        default:
            break
        }
    }
}
