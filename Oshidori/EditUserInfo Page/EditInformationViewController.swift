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
                    
            }
        case "誕生日":
            form +++ Section("誕生日編集")
                <<< DateRow(){
                    $0.title = "誕生日"
                    $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            
        default:
            self.dismiss(animated: false)
        }
    }
}
