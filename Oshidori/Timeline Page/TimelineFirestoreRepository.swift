//
//  FirestoreRepository.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/30.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import FirebaseFirestore

class TimelineFirestoreRepository {
    let db = Firestore.firestore()
    
    private func getTimelineColletionRef() -> CollectionReference {
        return db.collection("timelineMessages")
    }
    
    func updateCourageCount(messageId: String) {
        let timelineMessageRef = db.collection("timelineMessages").document(messageId)
        timelineMessageRef.getDocument { (Snapshot, Error) in
            var courageCount: Int = Snapshot?.get("courageCount") as! Int
            courageCount += 1
            let rep: [String : Any] = [
                "courageCount": courageCount
            ]
            timelineMessageRef.updateData(rep)
        }
    }
    
    func updateSupportCount(messageId: String) {
        let timelineMessageRef = db.collection("timelineMessages").document(messageId)
        timelineMessageRef.getDocument { (Snapshot, Error) in
            var supportCount: Int = Snapshot?.get("supportCount") as! Int
            supportCount += 1
            let rep: [String : Any] = [
                "supportCount": supportCount
            ]
            timelineMessageRef.updateData(rep)
        }
    }
    
    func loadTimelineMessage(completion: @escaping (([RepresentationMessage]) -> Void)){
        var timelineMessages: [RepresentationMessage] = []
        let collectionRef = getTimelineColletionRef()
        collectionRef.order(by: "created", descending: true).getDocuments() { (querySnapshot, err) in
            // エラーだったらリターンするよ
            guard err == nil else { return }
            for document in querySnapshot!.documents {
                let timelineMessage = RepresentationMessage(data: document.data())
                timelineMessages.append(timelineMessage)
//                guard let content = document.get("content") else { return }
//                guard let date = document.get("created") else { return }
//                guard let contentType = document.get("contentType") else { return }
//                guard let messageId = document.get("messageId") else { return }
//                guard let courageCount = document.get("courageCount") else { return }
//                guard let supportCount = document.get("supportCount") else { return }
//                guard let senderId = document.get("senderId") else { return }
//                let dateTimestamp = date as! Timestamp
//                print(dateTimestamp.dateValue())
//                let dateString = self.convertDateToString(timestampDate: dateTimestamp.dateValue() as NSDate)
//                self.timelineMessages.append((content: content as! String, sendDate: dateString, contentType: contentType as! String, messageId: messageId as! String, courageCount:courageCount as! Int, supportCount:supportCount as! Int, senderId: senderId as! String))
            }
            // firebaseにアクセスするよりも、tableViewのメソッドの方が先に走る。非同期通信だから。→リロードしてデータを反映させる。
        }
    }
}

extension TimelineFirestoreRepository {
    
    func convertDateToString(timestampDate: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let stringDate = dateFormatter.string(from: timestampDate as Date)
        return stringDate
    }

}
