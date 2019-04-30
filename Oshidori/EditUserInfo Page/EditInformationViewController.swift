//
//  EditInformation.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/29.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Eureka

class EditInformationViewController: FormViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var editContent:String?
    var birthday :Date?
    var name :String?
    
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
        case "ニックネーム":
            form +++ Section("ニックネーム編集")
                <<< TextRow(){ row in
                    row.title = "ニックネーム"
                    row.placeholder = "入力してね！"
                    row.onChange({ (TextRow) in
                        self.name = TextRow.value
                    })
                    
            }
        case "誕生日":
            form +++ Section("誕生日編集")
                <<< DateRow(){
                    $0.title = "誕生日"
                    $0.value = Date(timeIntervalSinceReferenceDate: 0)
                    $0.onChange({ (DateRow) in
                        self.birthday = DateRow.value
                    })
            }
            
        default:
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        guard let content = editContent else {
            return
        }
        
        if content == "ニックネーム" {
            guard let name = name else {
                alert("エラー", "値を変更してください", nil)
                return
            }
            // TODO: 保存する
        }
        if content == "誕生日" {
            guard let birthday = birthday else {
                alert("エラー", "値を変更してください", nil)
                return
            }
            // TODO: 保存する
        }
    }
}
