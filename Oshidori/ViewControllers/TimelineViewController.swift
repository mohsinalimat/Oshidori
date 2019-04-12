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
    var  timelineMessages:[(content:String, sendDate:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineTableView.register (UINib(nibName: "TimelineMessageTableViewCellTableViewCell", bundle: nil),forCellReuseIdentifier:"TimelineMessageCell")
        
        // セルの高さを自動設定
        timelineTableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // timelineMessages の初期化
        timelineMessages.removeAll()
        // firestoreからデータを取って、テーブルビューに反映
        getMessageDataFromFirestore_createTableView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineMessageCell", for: indexPath) as! TimelineMessageTableViewCellTableViewCell
        cell.setContentLabel(content: timelineMessages[indexPath.row].content)
        cell.setDataLabel(date: timelineMessages[indexPath.row].sendDate)
        return cell
    }
    
    // firebase 関連
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    private func getTimelineColletionRef() -> CollectionReference {
        // ROM専も使えるようにしたいからUidで弾くことはしないでおこう。
//        guard let uid = User.shared.getUid() else {
//            fatalError("Uidを取得できませんでした。")
//        }
        return db.collection("timelineMessages")
    }
    
    func getMessageDataFromFirestore_createTableView() {
        // firestoreからデータを持ってくる
        let collectionRef = getTimelineColletionRef()
        collectionRef.getDocuments() { (querySnapshot, err) in
            // エラーだったらリターンするよ
            guard err == nil else { return }
            for document in querySnapshot!.documents {
                guard let content = document.get("content") else { return }
                guard let date = document.get("created") else { return }
                let dateTimestamp = date as! Timestamp
                print(dateTimestamp.dateValue())
                let dateString = self.convertDateToString(timestampDate: dateTimestamp.dateValue() as NSDate)
                self.timelineMessages.append((content: content as! String, sendDate: dateString))
            }
            // firebaseにアクセスするよりも、tableViewのメソッドの方が先に走る。非同期通信だから。→リロードしてデータを反映させる。
            self.timelineTableView.reloadData()
        }
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
