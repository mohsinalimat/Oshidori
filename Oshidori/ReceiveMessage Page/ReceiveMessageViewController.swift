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
    
    @IBOutlet weak var receiveTableView: UITableView!
    
    private let refreshCtl = UIRefreshControl()
    
    private var readEndFlag = false
    private var lastDate: Date?
    private var afterDocument: DocumentSnapshot?
    private let getMessagesCount = 20
    
    // 未読を入れるため
    private let roomUserInfoRep = RoomFirestoreRepository()
    private var notReadMessage: [String] = []
    
    private var receiveMessageListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moveSendMessageButton.isHidden = true
        
        setDZNEmptyDataSetDelegate()
        addShadowForView(moveSendMessageButton)
        
        // 背景の色を消す
        receiveTableView.backgroundColor = .none
        
        // 上のぐるぐるの実装
        receiveTableView.refreshControl = refreshCtl
        refreshCtl.tintColor = OshidoriColor.primary
        refreshCtl.addTarget(self, action: #selector(reloadReceiveMessageTableView), for: .valueChanged)
        
        receiveTableView.register (UINib(nibName: "ReceiveMessageTableViewCell", bundle: nil),forCellReuseIdentifier:"receiveMesseageCell")
        
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
                if userInformation.roomId == "" {
                    return
                }
                // listenrの設置
                self.setReceiveMessagesListner()


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
        if userInfo.roomId == "" {
            completion()
        } else {
            roomUserInfoRep.getRoomMessageUserInfo(roomId: userInfo.roomId, uid: uid) { (notReadMessages) in
                self.notReadMessage = notReadMessages
                AppDelegate.badgeCount = notReadMessages.count
                completion()
            }
        }
    }
    
    func resetMessageInfo() {
        guard let userInfo = userInformation else {
            return
        }
        self.getRoomUserInfo() {
            if !(userInfo.roomId.isEmpty) {
                self.moveSendMessageButton.isHidden = false
                // firestoreからデータを取って、テーブルビューに反映
                // ここでリフレッシュのメソッドを呼ぶ
                self.getAndReload()
            }
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
        lastDate = nil
        afterDocument = nil
        readEndFlag = false
        resetMessageInfo()
        refreshCtl.endRefreshing()
    }
}

extension ReceiveMessageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMesseageCell", for: indexPath) as! ReceiveMessageTableViewCell
        
        // 上を引っ張った時にインデックスエラーになるので、エラー回避
        if messages.isEmpty {
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
        cell.isNotRead = message.isNotRead
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension
    }
}

extension ReceiveMessageViewController {
    // 下から５件くらいになったらリフレッシュ
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0)-2, section: 0)) != nil else {
            return
        }
        getAndReload()
    }
    
    func getAndReload() {
        if readEndFlag {
            return
        }
        self.makeQueryAndGetMessage()
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
    
    func makeQueryAndGetMessage() {
        // firestoreからデータを持ってくる
        guard  let collectionRef = getRoomMessagesCollectionRef() else {
            return
        }
        if readEndFlag {
            return
        }
        let queryRef = collectionRef.order(by: "sentDate", descending: true).limit(to: getMessagesCount)
        
        if let doc = afterDocument {
            queryRef.start(afterDocument: doc).getDocuments() { (querySnapshot, err) in
                self.dataToMessages(querySnapshot: querySnapshot, err: err)
            }
            
        } else {
            queryRef.start(at: [Date()]).getDocuments() { (querySnapshot, err) in
                self.dataToMessages(querySnapshot: querySnapshot, err: err)
            }
        }
        
    }
    
    func dataToMessages(querySnapshot: QuerySnapshot?, err: Error?) {
        
        if self.readEndFlag {
            return
        }
        // エラーだったらリターンするよ
        guard let documents = querySnapshot?.documents else {
            debugPrint(err?.localizedDescription)
            return
        }
        
        debugPrint("documents.count: \(documents.count)")
        // limit のgetCount以外の数を持ってきていたら、endFlagを立てる。0だったらreturn
        if !(documents.count == self.getMessagesCount) {
            self.readEndFlag = true
        }
        
        if documents.isEmpty {
            return
        }
        
        for document in documents {
            let receiveMessage = RepresentationMessage(data: document.data())
            self.messages.append(receiveMessage)
        }
        
        // notReadMessageに入っているIDを参照し、messagesのisNotReadを変更している
        // cellにも、messageにもisNotReadを持たせる。
        for (_, messageId) in self.notReadMessage.enumerated() {
            for (indexMessage, message) in self.messages.enumerated() {
                if message.messageId == messageId {
                    self.messages[indexMessage].isNotRead = true
                }
            }
        }
        // firebaseにアクセスするよりも、tableViewのメソッドの方が先に走る。非同期通信だから。→リロードしてデータを反映させる。
        self.receiveTableView.reloadData()
        self.afterDocument = documents.last
    
    }
    
    
    func setReceiveMessagesListner() {
        guard let collectionRef = getRoomMessagesCollectionRef() else {
            return
        }
        receiveMessageListener = collectionRef.addSnapshotListener({ (querySnapshot, error) in
            self.reloadReceiveMessageTableView()
        })
    }
}

extension ReceiveMessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if messages.isEmpty {
            return
        }
        // これをどこかに保存しなきゃ。
        guard let messageId = messages[indexPath.row].messageId else {
            return
        }
        
        // 未読の削除の処理
        guard let userInfo = userInformation else {
            return
        }
        guard let uid = User.shared.getUid() else {
            return
        }
        
        // 下の３つは未読を消す処理
        roomUserInfoRep.delete(roomId: userInfo.roomId, uid: uid, messageId: messageId)
        for (index, removeId) in notReadMessage.enumerated() {
            if removeId == messageId {
                notReadMessage.remove(at: index)
            }
        }
        messages[indexPath.row].isNotRead = false
        // セルを単独で更新する
        self.receiveTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        
        // badgeの個数を合わせる
        AppDelegate.badgeCount = notReadMessage.count
        
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
