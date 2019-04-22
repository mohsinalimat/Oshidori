//
//  MessageViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/8.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // firebase関連
    let db = Firestore.firestore()
    
    @IBOutlet weak var moveSendMessageButton: UIButton!
    
    // userInfo を入れておく場所
    var userInformation : UserInformation?
    
    // let messages:[(content:String, date:String)] = [(content:"ありがと", date : "2019/10/28"), (content:"content2", date: "2019/10/04")]
    var  messages:[(content:String, sendDate:String)] = []
    
    @IBOutlet weak var receiveTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moveSendMessageButton.isHidden = true
        // 登録をすることで、カスタムセルを利用できるようになる。
        // nibファイルはxibファイルの作成と同時に作られるらしい。
        // nibNameには.xibの名前。forCellReuseIdentifier には、その中にあるcellに命名したidentifierを記述
        receiveTableView.register (UINib(nibName: "ReceiveMessageTableViewCell", bundle: nil),forCellReuseIdentifier:"receiveMesseageCell")
        
        // セルの高さを内容によって可変にする
        receiveTableView.estimatedRowHeight = 50 //予想のセルの高さ //入れないとワーニングが出る
        receiveTableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // messages の初期化
        messages.removeAll()
        // userInformaitonの初期化。情報を持ってくる
        getUserInformationRef().getDocument{ (document, error) in
            if let userInformation = document.flatMap({
                $0.data().flatMap({ (data) in
                    return UserInformation(data: data)
                })
            }) {
                self.userInformation = userInformation
                debugPrint("🌞City: \(userInformation.name)")
                if !(userInformation.roomId.isEmpty) {
                    self.moveSendMessageButton.isHidden = false
                    // firestoreからデータを取って、テーブルビューに反映
                    self.getMessageDataFromFirestore_createTableView()
                }
                
            } else {
                debugPrint("Document does not exist")
            }
        }
        
        
        
    }

    @IBAction func testQRcode(_ sender: Any) {
        moveQRcodePage()
    }
    
    @IBAction func didTapMoveUserEditButton(_ sender: Any) {
        moveUserEditPage()
    }
    
    @IBAction func didTapMoveSendMessageButton(_ sender: Any) {
        // chatStoryboard
        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "ChatStoryboard")
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // as! ReceiveMessageTableViewCell をつけないと、ReceiveMessageTableViewCell.swiftのパーツをいじることができない。
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMesseageCell", for: indexPath) as! ReceiveMessageTableViewCell
        cell.setContentLabel(content: messages[indexPath.row].content)
        cell.setDataLabel(date: messages[indexPath.row].sendDate)
        return cell
    }
    
    @IBAction func moveQRcode(_ sender: Any) {
        moveQRcodePage()
    }
    
    @IBAction func didTopLogoutButton(_ sender: Any) {
        User.shared.logout()
        moveLoginPage()
    }
}

extension MessageViewController {
    
    private func getUserInformationRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("users").document(uid).collection("info").document(uid)
    }
    
    private func getRoomMessagesCollectionRef() -> CollectionReference? {
        guard let roomId = userInformation?.roomId else {
            return nil
        }
        return db.collection("rooms").document(roomId).collection("messages")
    }
    
    func getMessageDataFromFirestore_createTableView() {
        // firestoreからデータを持ってくる
        guard  let collectionRef = getRoomMessagesCollectionRef() else {
            return
        }
        collectionRef.order(by: "created", descending: true).getDocuments() { (querySnapshot, err) in
            // エラーだったらリターンするよ
            guard err == nil else { return }
            for document in querySnapshot!.documents {
                guard let content = document.get("content") else { return }
                guard let date = document.get("created") else { return }
                let dateTimestamp = date as! Timestamp
                let dateString = self.convertDateToString(timestampDate: dateTimestamp.dateValue() as NSDate)
                self.messages.append((content: content as! String, sendDate: dateString))
            }
            // firebaseにアクセスするよりも、tableViewのメソッドの方が先に走る。非同期通信だから。→リロードしてデータを反映させる。
            self.receiveTableView.reloadData()
        }
    }
}

