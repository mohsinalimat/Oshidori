//
//  UserEditViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/16.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Firebase

class UserInfoEditViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var birthdayDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        moveMessagePage()
    }
    
    // firebase 関連
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    private func getColletionRef() -> CollectionReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("users").document(uid).collection("name")
    }
    
    @IBAction func didTopSendButton(_ sender: Any) {
        guard let name = nameField.text else {
            alert("error", "ニックネームを入力してください!", nil)
            return
        }
        if name ==  "" {
            alert("error", "ニックネームを入力してください!", nil)
            return
        }
        
        let birthday = birthdayDatePicker.date
        let created = Date()
        let userInfo = UserInformation(name: name, birthday: birthday, partnerId: "", roomId: "", created: created)
        
        save(userInfo)
        
    }
    
    func save(_ userInfo: UserInformation) {
        
        print("Firestoreへセーブ")
        let userCollectionRef = getColletionRef()
        userCollectionRef.addDocument(data: userInfo.representation)
        
    }
    
    
    
}
