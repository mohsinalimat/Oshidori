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
import DZNEmptyDataSet

protocol ReceiveMessageViewControllerDelegate: class {
    func reloadReceiveMessageTableView()
}

class ReceiveMessageViewController: UIViewController {
    
    // firebase関連
    let db = Firestore.firestore()
    
    @IBOutlet weak var moveSendMessageButton: UIButton!
    
    // userInfo を入れておく場所
    var userInformation : UserInformation?
    
    var messages:[RepresentationMessage] = []
    var tmpMessages:[RepresentationMessage]?
    
    @IBOutlet weak var receiveTableView: UITableView!
    
    private var lastDate: Date?
    
    private let refreshCtl = UIRefreshControl()
    
    // 未読を入れるため
    private let roomUserInfoRep = RoomFirestoreRepository()
    private var notReadMessage: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moveSendMessageButton.isHidden = true
        
        setDZNEmptyDataSetDelegate()
        addShadowForView(moveSendMessageButton)
        
        // 背景の色を指定
        receiveTableView.backgroundColor = OshidoriColor.background
        
        // 上のぐるぐるの実装
        receiveTableView.refreshControl = refreshCtl
        refreshCtl.tintColor = OshidoriColor.primary
        refreshCtl.addTarget(self, action: #selector(reloadReceiveMessageTableView), for: .valueChanged)
        
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
                // 未読処理
                self.getRoomUserInfo() {
                    if !(userInformation.roomId.isEmpty) {
                        self.moveSendMessageButton.isHidden = false
                        // firestoreからデータを取って、テーブルビューに反映
                        if let lastDate = self.lastDate {
                            self.getMessageDataFromFirestore_createTableView(lastDate: lastDate)
                        } else {
                            self.getMessageDataFromFirestore_createTableView(lastDate: Date())
                        }
                    }
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
}

extension ReceiveMessageViewController {
    func getRoomUserInfo(completion: @escaping () -> ()) {
        guard let userInfo = self.userInformation else {
            return
        }
        guard let uid = User.shared.getUid() else {
            return
        }
        roomUserInfoRep.getRoomMessageUserInfo(roomId: userInfo.roomId, uid: uid) { (notReadMessages) in
            self.notReadMessage = notReadMessages
            completion()
        }
    }
}



extension ReceiveMessageViewController {
    func addShadowForView(_ button: UIButton) {
        button.layer.masksToBounds = false
        button.layer.shadowOffset = CGSize(width: 0, height: 5); // 下向きの影
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
    }
}

extension ReceiveMessageViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func setDZNEmptyDataSetDelegate() {
        receiveTableView.emptyDataSetDelegate = self
        receiveTableView.emptyDataSetSource = self
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "ReceiveMessage_null")
    }
}

extension ReceiveMessageViewController: ReceiveMessageViewControllerDelegate {
    @objc func reloadReceiveMessageTableView() {
        messages.removeAll()
        tmpMessages = nil
        lastDate = nil
        getMessageDataFromFirestore_createTableView(lastDate: Date())
        refreshCtl.endRefreshing()
    }
}

extension ReceiveMessageViewController: UITableViewDataSource {
    
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
        
        guard let messages = tmpMessages else {
            return UITableViewCell()
        }
        let message = messages[indexPath.row]
        cell.setContentLabel(content: message.content ?? "")
        if let date = message.sentDate {
            let sentDate = convertDateToString(timestampDate: date as NSDate)
            cell.setSentDataLabel(date: sentDate)
        }
        cell.setContentTypeImage(contentType: message.contentType ?? "")
        cell.setNameLabel(name: message.senderName ?? "")
        // セルの処理
        for messageId in notReadMessage {
            if message.messageId == messageId {
                cell.isNotRead = true
            }
        }
        // TODO: viewの角を丸くする
        cell.tag = indexPath.row
        
        return cell
    }
}

extension ReceiveMessageViewController {
    // 下から５件くらいになったらリフレッシュ
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0)-2, section: 0)) != nil else {
            return
        }
        // ここでリフレッシュのメソッドを呼ぶ
        if let lastDate = self.lastDate {
            self.getMessageDataFromFirestore_createTableView(lastDate: lastDate)
        } else {
            self.getMessageDataFromFirestore_createTableView(lastDate: Date())
        }
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
    
    func getMessageDataFromFirestore_createTableView(lastDate: Date) {
        // firestoreからデータを持ってくる
        guard  let collectionRef = getRoomMessagesCollectionRef() else {
            return
        }
        collectionRef.order(by: "sentDate", descending: true).limit(to: 10).start(at: [lastDate]).getDocuments() { (querySnapshot, err) in
            // エラーだったらリターンするよ
            guard err == nil else { return }
            for document in querySnapshot!.documents {
                let receiveMessage = RepresentationMessage(data: document.data())
                if let sentDate = receiveMessage.sentDate {
                    if self.lastDate == sentDate {
                        return
                    }
                    self.lastDate = sentDate
                }
                self.messages.append(receiveMessage)
            }
            self.tmpMessages = self.messages
            // firebaseにアクセスするよりも、tableViewのメソッドの方が先に走る。非同期通信だから。→リロードしてデータを反映させる。
            self.receiveTableView.reloadData()
        }
    }
}

extension ReceiveMessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // これをどこかに保存しなきゃ。
        guard let messageId = messages[indexPath.row].messageId else {
            return
        }
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
