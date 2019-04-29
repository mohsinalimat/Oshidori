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
    
    let prefecturesForPicker:[String] = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県",
                                         "茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県",
                                         "新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県",
                                         "静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県",
                                         "奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県",
                                         "徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県",
                                         "熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("ユーザー")
            <<< LabelRow(){ row in
                row.title = "ニックネーム"
                row.value = "やまたつ"
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
                row.value = "未設定"
                
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
                row.title = "移住地"
                row.value = "未設定"
                
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
                row.value = "ナッキー"
        }
        
        
        // userInformaitonの初期化。情報を持ってくる
//        getUserInformationRef().getDocument{ (document, error) in
//            if let userInformation = document.flatMap({
//                $0.data().flatMap({ (data) in
//                    return UserInformation(data: data)
//                })
//            }) {
//                // 上記で得た内容を保存する
//                self.userInformation = userInformation
//                debugPrint("🌞City: \(userInformation.name)")
//            } else {
//                debugPrint("Document does not exist")
//            }
//        }
        
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
//        guard let name = nameField.text else {
//            alert("error", "ニックネームを入力してください!", nil)
//            return
//        }
//        if name ==  "" {
//            alert("error", "ニックネームを入力してください!", nil)
//            return
//        }
//
//
//        let birthday = birthdayDatePicker.date
//        let created = Date()
//
//        let userInfo = UserInformation(name: name, birthday: birthday, partnerId: userInformation.partnerId,
//                                       roomId: userInformation.roomId, created: created)
//
//        save(userInfo)
        
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

extension EditUserInfoViewController {
    
    func moveEditInformationPage(_ content: String) {
        let storyboard = UIStoryboard(name: "EditInformation", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "EditInformationStoryboard") as! EditInformationViewController
        VC.editContent = content
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
}
