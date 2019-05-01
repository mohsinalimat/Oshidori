//
//  TimelineViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/11.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var timelineTableView: UITableView!
    var  timelineMessages:[(content:String, sendDate:String, contentType:String,
        messageId:String, courageCount:Int, supportCount:Int, senderId:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineTableView.register (UINib(nibName: "TimelineMessageTableViewCellTableViewCell", bundle: nil),forCellReuseIdentifier:"TimelineMessageCell")
        
        // セルの高さを自動設定
        timelineTableView.estimatedRowHeight = 50 //予想のセルの高さ //入れないとワーニングが出る
        timelineTableView.rowHeight = UITableView.automaticDimension
        
        // timelineMessages の初期化
        timelineMessages.removeAll()
        // firestoreからデータを取って、テーブルビューに反映
        getMessageDataFromFirestore_createTableView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineMessageCell", for: indexPath) as! TimelineMessageTableViewCell
        cell.setContentLabel(content: timelineMessages[indexPath.row].content)
        cell.setDataLabel(date: timelineMessages[indexPath.row].sendDate)
        cell.setContentTypeImage(contentType: timelineMessages[indexPath.row].contentType)
        cell.setCourageCountLabel(courageCount: timelineMessages[indexPath.row].courageCount)
        cell.setSupportCountLabel(supportCount: timelineMessages[indexPath.row].supportCount)
        
        cell.setMessageId(messageId: timelineMessages[indexPath.row].messageId)
        cell.setSenderId(senderId: timelineMessages[indexPath.row].senderId)
        // いいねの実装に必要かも
        cell.courageButton.tag = indexPath.row
        cell.supportButton.tag = indexPath.row
        return cell
    }
    
    // firebase 関連
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private func getTimelineColletionRef() -> CollectionReference {
        return db.collection("timelineMessages")
    }
    
    func getMessageDataFromFirestore_createTableView() {
        // firestoreからデータを持ってくる
        let collectionRef = getTimelineColletionRef()
        collectionRef.order(by: "created", descending: true).getDocuments() { (querySnapshot, err) in
            // エラーだったらリターンするよ
            guard err == nil else { return }
            for document in querySnapshot!.documents {
                guard let content = document.get("content") else { return }
                guard let date = document.get("created") else { return }
                guard let contentType = document.get("contentType") else { return }
                guard let messageId = document.get("messageId") else { return }
                guard let courageCount = document.get("courageCount") else { return }
                guard let supportCount = document.get("supportCount") else { return }
                guard let senderId = document.get("senderId") else { return }
                let dateTimestamp = date as! Timestamp
                print(dateTimestamp.dateValue())
                let dateString = self.convertDateToString(timestampDate: dateTimestamp.dateValue() as NSDate)
                self.timelineMessages.append((content: content as! String, sendDate: dateString, contentType: contentType as! String, messageId: messageId as! String, courageCount:courageCount as! Int, supportCount:supportCount as! Int, senderId: senderId as! String))
            }
            // firebaseにアクセスするよりも、tableViewのメソッドの方が先に走る。非同期通信だから。→リロードしてデータを反映させる。
            self.timelineTableView.reloadData()
        }
    }
}
