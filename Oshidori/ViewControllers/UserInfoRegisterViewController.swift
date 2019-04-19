//
//  UserInfoRegisterViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/16.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Firebase

class UserInfoRegisterViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var birthdayDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // firebase 関連
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    private func getDocumentRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("users").document(uid).collection("info").document(uid)
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
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
        
        save(userInfo,completion: nil!)
    }
    
    func save(_ userInfo: UserInformation,completion: (Error?) -> Void) {
        print("Firestoreへセーブ")
        let userDocumentRef = getDocumentRef()
        // userDocumentRef.setData(userInfo.representation)
        userDocumentRef.setData(userInfo.representation)
    }
    
    //let cl: (Error?) -> Void = ({ err in
        //            if let err = err {
        //                print("Error updating document: \(err)")
        //            } else {
        //                print("Document successfully updated")
        //
        //            }
        //        })
        //        userCollectionRef.updateData(["partnerId":partnerId], completion: cl)
    //}

}
