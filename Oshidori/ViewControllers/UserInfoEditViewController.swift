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

class UserInfoEditViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var birthdayDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    var userInformation: UserInformation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // userInformaitonの初期化。情報を持ってくる
        getUserInformationRef().getDocument{ (document, error) in
            if let userInformation = document.flatMap({
                $0.data().flatMap({ (data) in
                    return UserInformation(data: data)
                })
            }) {
                // 上記で得た内容を保存する
                self.userInformation = userInformation
                debugPrint("🌞City: \(userInformation.name)")
            } else {
                debugPrint("Document does not exist")
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        moveMessagePage()
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
    private func getUserInformationRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("users").document(uid).collection("info").document(uid)
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
        
        let userInfo = UserInformation(name: name, birthday: birthday, partnerId: userInformation.partnerId,
                                       roomId: userInformation.roomId, created: created)
        
        save(userInfo)
        
    }
    
    func save(_ userInfo: UserInformation) {
        HUD.show(.progress)
        print("Firestoreへセーブ")
        let userDocumentRef = getDocumentRef()
        userDocumentRef.updateData(userInfo.editRepresentation){ err in
            if let err = err {
                debugPrint("error...\(err)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            HUD.hide()
        }
    }
}
