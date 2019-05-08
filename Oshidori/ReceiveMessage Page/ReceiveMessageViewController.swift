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

protocol ReceiveMessageViewControllerDelegate: class {
    func reloadDate()
}

class ReceiveMessageViewController: UIViewController, UITableViewDataSource, ReceiveMessageViewControllerDelegate {
    
    func reloadDate() {
        messages.removeAll()
        getMessageDataFromFirestore_createTableView()
    }
    
    // firebase関連
    let db = Firestore.firestore()
    
    @IBOutlet weak var moveSendMessageButton: UIButton!
    
    // userInfo を入れておく場所
    var userInformation : UserInformation?
    
    var messages:[(content:String, sendDate:String, name:String, contentType:String, messageId:String)] = []
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    @IBAction func didTapMoveSendMessageButton(_ sender: Any) {
        // chatStoryboard
        let storyboard = UIStoryboard(name: "SendMessage", bundle: nil)
        guard let VC = storyboard.instantiateViewController(withIdentifier: "SendMessageStoryboard") as? SendMessageViewController else { return }
        VC.delegate = self
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return messages.count
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // as! ReceiveMessageTableViewCell をつけないと、ReceiveMessageTableViewCell.swiftのパーツをいじることができない。
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMesseageCell", for: indexPath) as! ReceiveMessageTableViewCell
        cell.setContentLabel(content: messages[indexPath.row].content)
        cell.setDataLabel(date: messages[indexPath.row].sendDate)
        cell.setContentTypeImage(contentType: messages[indexPath.row].content)
        cell.setNameLabel(name: messages[indexPath.row].name)
        cell.setContentTypeImage(contentType: messages[indexPath.row].contentType)
        // TODO: viewの角を丸くする
        cell.messageView.layer.cornerRadius = 0.8
        cell.messageView.backgroundColor = OshidoriColor.light
        cell.tag = indexPath.row
        return cell
    }
}

extension ReceiveMessageViewController {
    
    private func getUserInformationRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            alert("エラー", "申し訳ありません。ユーザ情報が取得できませんでした。ログインし直してください。") {
                self.moveLoginPage()
            }
            return db.collection("users").document() // 一応書いておかないとエラーになっちゃう
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
        collectionRef.order(by: "sentDate", descending: true).getDocuments() { (querySnapshot, err) in
            // エラーだったらリターンするよ
            guard err == nil else { return }
            for document in querySnapshot!.documents {
                guard let content = document.get("content") else { return }
                guard let date = document.get("sentDate") else { return }
                guard let name = document.get("senderName") else { return }
                guard let contentType = document.get("contentType") else { return }
                guard let messageId = document.get("messageId") else { return }
                let dateTimestamp = date as! Timestamp
                let dateString = self.convertDateToString(timestampDate: dateTimestamp.dateValue() as NSDate)
                self.messages.append((content: content as! String, sendDate: dateString,
                                  name: name as! String, contentType: contentType as! String, messageId: messageId as! String))
            }
            // firebaseにアクセスするよりも、tableViewのメソッドの方が先に走る。非同期通信だから。→リロードしてデータを反映させる。
            self.receiveTableView.reloadData()
        }
    }
}

extension ReceiveMessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // これをどこかに保存しなきゃ。
        let messageId = messages[indexPath.row].messageId
        moveMessageRoomPage(messageId: messageId)
    }
    
    func moveMessageRoomPage(messageId: String) {
        let storyboard = UIStoryboard(name: "MessageRoomViewController", bundle: nil)
        guard let VC = storyboard.instantiateViewController(withIdentifier: "MessageRoomViewController") as? MessageRoomViewController else {
            return
        }
        VC.messageId = messageId
        self.navigationController?.pushViewController(VC, animated: true)
    }
}
