//
//  FirestoreUserInfomaitonRepository.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/24.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirestoreUserInformationRepository {
    // firebase 関連
    private let db = Firestore.firestore()
    func getDocumentRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("users").document(uid).collection("info").document(uid)
    }
    
    func save(_ userInfo: UserInformation, completion: @escaping () -> Void )  {
        debugPrint("Firestoreへセーブ")
        let userInfoDocumentRef = getDocumentRef()
        userInfoDocumentRef.setData(userInfo.representation) { err in
            if let err = err {
                debugPrint("error...\(err)")
            } else {
                completion()
            }
        }
    }
        
}
