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
    
    
    
    func save(messageId: String) {
        let timelineMessageRef = db.collection("timelineMessages").document(messageId)
        timelineMessageRef.getDocument { (Snapshot, Error) in
//            debugPrint(Snapshot?.data())
//            debugPrint(messageId)
//            debugPrint(Snapshot?.get("courageCount"))
//            debugPrint(Snapshot?.metadata)
//            debugPrint(Snapshot.debugDescription)
            
            var courageCount: Int = Snapshot?.get("courageCount") as! Int
            courageCount += 1
            let rep: [String : Any] = [
                "courageCount": courageCount
            ]
            timelineMessageRef.updateData(rep)
        }
        
    }
}
