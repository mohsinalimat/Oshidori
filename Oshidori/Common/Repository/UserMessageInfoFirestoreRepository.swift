//
//  MypageRepository.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/1.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import FirebaseFirestore

class UserMessageInfoFirestoreRepository {
    
    let db = Firestore.firestore()
    
    func getUserMessageInfo(uid: String, completion: @escaping ((UserMessageInfo) -> ())) {
        var userMessageInfo: UserMessageInfo?
        let userMessageInfoDocRef = db.collection("usersMessagesInfo").document(uid)
        userMessageInfoDocRef.getDocument { (Snapshot, Error) in
            if let _ = Error {
                
            } else if let data = Snapshot?.data(){
                userMessageInfo = UserMessageInfo(data: data)
            }
            guard let userMessageInfo = userMessageInfo else {
                return
            }
            completion(userMessageInfo)
        }
    }
}

// update
extension UserMessageInfoFirestoreRepository {
    
    func updateCourageCount(uid: String) {
        let usersMessagesInfoRef = db.collection("usersMessagesInfo").document(uid)
        usersMessagesInfoRef.getDocument { (Snapshot, Error) in
            var courageCount: Int = Snapshot?.get("courageCount") as! Int
            courageCount += 1
            let rep: [String : Any] = [
                "courageCount": courageCount
            ]
            usersMessagesInfoRef.updateData(rep)
        }
    }
    
    func updateSupportCount(uid: String) {
        let usersMessagesInfoRef = db.collection("usersMessagesInfo").document(uid)
        usersMessagesInfoRef.getDocument { (Snapshot, Error) in
            var supportCount: Int = Snapshot?.get("supportCount") as! Int
            supportCount += 1
            let rep: [String : Any] = [
                "supportCount": supportCount
            ]
            usersMessagesInfoRef.updateData(rep)
        }
    }
    
    func updateMessageCount(uid: String) {
        let usersMessagesInfoRef = db.collection("usersMessagesInfo").document(uid)
        usersMessagesInfoRef.getDocument { (Snapshot, Error) in
            var count: Int = Snapshot?.get("messageCount") as! Int
            count += 1
            let rep: [String : Any] = [
                "messageCount": count
            ]
            usersMessagesInfoRef.updateData(rep)
        }
    }
}
