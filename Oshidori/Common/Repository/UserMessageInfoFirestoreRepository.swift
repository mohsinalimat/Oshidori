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
            guard let snapshot = Snapshot else {
                return
            }
            let courageCount = snapshot.get("courageCount") as? Int
            if let count = courageCount {
                let addedCount = count + 1
                let rep: [String : Any] = [
                    "supportCount": addedCount
                ]
                usersMessagesInfoRef.updateData(rep)
            }
        }
    }
    
    func updateSupportCount(uid: String) {
        let usersMessagesInfoRef = db.collection("usersMessagesInfo").document(uid)
        usersMessagesInfoRef.getDocument { (Snapshot, Error) in
            guard let snapshot = Snapshot else {
                return
            }
            let supportCount = snapshot.get("supportCount") as? Int
            if let count = supportCount {
                let addedCount = count + 1
                let rep: [String : Any] = [
                    "supportCount": addedCount
                ]
                usersMessagesInfoRef.updateData(rep)
            }
        }
    }
    
    func updateMessageCount(uid: String) {
        let usersMessagesInfoRef = db.collection("usersMessagesInfo").document(uid)
        usersMessagesInfoRef.getDocument { (Snapshot, Error) in
            guard let snapshot = Snapshot else {
                return
            }
            let messageCount = snapshot.get("messageCount") as? Int
            if let count = messageCount {
                let addedCount = count + 1
                let rep: [String : Any] = [
                    "messageCount": addedCount
                ]
                usersMessagesInfoRef.updateData(rep)
            }
        }
    }
}
