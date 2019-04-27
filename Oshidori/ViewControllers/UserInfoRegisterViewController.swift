//
//  UserInfoRegisterViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/16.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import PKHUD

class UserInfoRegisterViewController: UIViewController, UITextFieldDelegate {
    
    
    // TODO: ここから離脱した人のことを考える。Authは登録したけど、Userは登録していない人

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var birthdayField: UITextField!
    var toolBar: UIToolbar!
    var birthday: Date!
    
    let userInfoService = UserInfoService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.becomeFirstResponder()
        
        userInfoService.delegate = self
        
        nameField.delegate = self
        birthdayField.delegate = self
        // Do any additional setup after loading the view.
        //datepicker上のtoolbarのdoneボタン
        
        toolBar = UIToolbar()
        toolBar.sizeToFit()
        let toolBarBtn = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(doneBtn))
        toolBar.items = [toolBarBtn]
        birthdayField.inputAccessoryView = toolBar
    }
    
    @IBAction func birthdayFIeldEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControl.Event.valueChanged)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //datepickerが選択されたらtextfieldに表示
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "yyyy/MM/dd";
        birthdayField.text = dateFormatter.string(from: sender.date)
        birthday = sender.date
    }
    
    //toolbarのdoneボタン
    @objc func doneBtn(){
        birthdayField.resignFirstResponder()
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        guard let name = nameField.text, let birthday = birthday else {
            alert("error", "ニックネームか誕生日を入力してください!", nil)
            return
        }
        if name ==  "" {
            alert("error", "ニックネームを入力してください!", nil)
            return
        }
        let created = Date()
        let userInfo = UserInformation(name: name, birthday: birthday, partnerId: "", roomId: "", created: created)
        HUD.show(.progress)
        UserInfoService.shared.save(userInfo)
    }
    
}

extension UserInfoRegisterViewController: UserInfoServiceDelegate {
    func saved() {
        HUD.hide()
        moveMessagePage()
    }
    
    func loaded() {
        
    }    
}
