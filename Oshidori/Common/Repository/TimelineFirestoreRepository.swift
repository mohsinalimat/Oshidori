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
    
// ここで、タイムラインから持ってくる数を変更する！！！
    func loadTimelineMessage(lastDate: Date, completion: @escaping (([RepresentationMessage],Date) -> Void)){
        var timelineMessages: [RepresentationMessage] = []
        let collectionRef = getTimelineColletionRef().order(by: "sentDate", descending: true).limit(to: 20).start(at: [lastDate])
        collectionRef.getDocuments { (querySnapshot, err) in
            guard err == nil else { return }
            var lastDate = Date()
            for document in querySnapshot!.documents {
                let timelineMessage = RepresentationMessage(data: document.data())
                timelineMessages.append(timelineMessage)
                if let sentDate = timelineMessage.sentDate {
                    lastDate = sentDate
                }
            }
            completion (timelineMessages, lastDate)
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
