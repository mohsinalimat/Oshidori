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
    
    let editContentArray:[String] = ["ニックネーム","誕生日"]
    var editContent:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let content = editContent else {
            moveUserEditPage()
            return
        }
        
        switch content {
        case "ニックネーム":
            form +++ Section("Section1")
                <<< TextRow(){ row in
                    row.title = "ニックネーム"
                    row.placeholder = "入力してね！"
                    
                }
        case "誕生日":
        form +++ Section("編集")
            <<< DateRow(){
                $0.title = "Date Row"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            
        default:
            break
        }
        
        
    }
    
}
