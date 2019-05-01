//
//  MypageRepository.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/1.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import FirebaseFirestore

class MypageFirestoreRepository {
    
    let db = Firestore.firestore()
    
    
    
    func getUserMessageInfo(uid: String, completion: @escaping ((UserMessageInfo) -> ())) {
        var userMessageInfo: UserMessageInfo?
        let userMessageInfoDocRef = db.collection("usersMessagesInfo").document(uid)
        userMessageInfoDocRef.getDocument { (Snapshot, Error) in
            if let error = Error {
                debugPrint(error.localizedDescription)
            } else if let data = Snapshot?.data(){
                userMessageInfo = UserMessageInfo(data: data)
            }
            guard let userMessageInfo = userMessageInfo else {
                return
            }
            completion(userMessageInfo)
        }
    }
    
    func test() -> DocumentReference {
        return db.collection("usersMessagesInfo").document()
    }
    
    
    
}
