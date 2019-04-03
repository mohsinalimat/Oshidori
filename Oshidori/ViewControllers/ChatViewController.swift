//
//  ChatViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/3.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import MessageKit

class ChatViewController: UIViewController {

    @IBOutlet weak var testField: UITextField!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var testButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    
    //private var messages: [Message] = []
    
    private func getColletionRef() -> CollectionReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("users").document(uid).collection("messages")
    }
    
    func save(_ message: Message) {
        print("Firestoreへセーブ")
        let collectionRef = getColletionRef()
        
        if let id = message.id { // データがある場合
            let documentRef = collectionRef.document(id)
            // データの上書きを行なっている
            documentRef.setData(message.toDictionary())
        } else { // データがない場合
            // データを追加している
            let documentRef = collectionRef.addDocument(data: message.toDictionary())
            message.id = documentRef.documentID
        }
    }
    
    @IBAction func didTapTestButton(_ sender: Any) {
        guard let content = testField.text else {
            alert("エラー", "入力してください", nil)
            return
        }
        let message = Message()
        message.content = content
        save(message)
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
