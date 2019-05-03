//
//  FirestoreUserInfomaitonRepository.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/24.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import FirebaseFirestore

class UserInformationFirestoreRepository {
    // firebase 関連
    private let db = Firestore.firestore()
    func getUserInfoDocumentRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("users").document(uid).collection("info").document(uid)
    }
    
    func getMessageInfoDocumentRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("usersMessagesInfo").document(uid)
    }
    
    func save(_ userInfo: UserInformation, completion: @escaping () -> Void )  {
        debugPrint("Firestoreへセーブ")
        let userInfoDocumentRef = getUserInfoDocumentRef()
        userInfoDocumentRef.setData(userInfo.representation) { err in
            if let err = err {
                debugPrint("error...\(err)")
            } else {
                completion()
            }
        }
        let messageInfoDocumentRef = getMessageInfoDocumentRef()
        messageInfoDocumentRef.setData(UserMessageInfo.shared.firstRepresentation){ err in
            if let err = err {
                debugPrint("error...\(err)")
            } else {
                completion()
            }
        }
    }
    
    func update(_ userInfo: UserInformation, completion: @escaping () -> Void )  {
        debugPrint("Firestoreへセーブ")
        let userInfoDocumentRef = getUserInfoDocumentRef()
        userInfoDocumentRef.setData(userInfo.representation) { err in
            if let err = err {
                debugPrint("error...\(err)")
            } else {
                completion()
            }
        }
    }
    
    func getUserInfo(completion: @escaping (UserInformation) -> Void ) {
        let userInfoDocumentRef = getUserInfoDocumentRef()
        userInfoDocumentRef.getDocument { (snapshot, error) in
            guard let data = snapshot?.data() else {
                return
            }
            let userInfo = UserInformation(data: data)
            completion(userInfo)
        }
    }
    
    
    
}

