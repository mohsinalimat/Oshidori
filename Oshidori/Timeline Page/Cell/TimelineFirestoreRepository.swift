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

}
