//
//  FirestoreUserInfomaitonRepository.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/24.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class UserInformationFirestoreRepository {
    // firebase 関連
    private let db = Firestore.firestore()
    private func getUserInfoDocumentRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            return db.collection("users").document("error")
        }
        return db.collection("users").document(uid).collection("info").document(uid)
    }
    
    private func getPartnerUserInfoDocumentRef(partnerId: String) -> DocumentReference {
        return db.collection("users").document(partnerId).collection("info").document(partnerId)
    }
    
    private func getMessageInfoDocumentRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            return db.collection("usersMessagesInfo").document("error")
        }
        return db.collection("usersMessagesInfo").document(uid)
    }
    
    func save(_ userInfo: UserInformation, completion: @escaping () -> Void )  {
        let userInfoDocumentRef = getUserInfoDocumentRef()
        userInfoDocumentRef.setData(userInfo.representation) { err in
            if let _ = err {
                // TODO:エラー処理
            } else {
                completion()
            }
        }
        let messageInfoDocumentRef = getMessageInfoDocumentRef()
        messageInfoDocumentRef.setData(UserMessageInfo.shared.firstRepresentation){ err in
            if let _ = err {
                // TODO:エラー処理
            } else {
                completion()
            }
        }
    }
    
    func update(_ userInfo: UserInformation, completion: @escaping () -> Void )  {
        let userInfoDocumentRef = getUserInfoDocumentRef()
        userInfoDocumentRef.setData(userInfo.representation) { err in
            if let _ = err {
                // TODO:エラー処理
            } else {
                completion()
            }
        }
    }
    
    func updatePartnerInfo(_ parnerInfo: UserInformation, partnerId: String, completion: @escaping () -> Void )  {
        let partnerInfoDocumentRef = getPartnerUserInfoDocumentRef(partnerId: partnerId)
        partnerInfoDocumentRef.setData(parnerInfo.representation) { err in
            if let _ = err {
                // TODO:エラー処理
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
    
    func getPartnerUserInfo(partnerId: String,completion: @escaping (UserInformation) -> Void ) {
        let partnerUserInfoDocumentRef = getPartnerUserInfoDocumentRef(partnerId: partnerId)
        partnerUserInfoDocumentRef.getDocument { (snapshot, error) in
            guard let data = snapshot?.data() else {
                return
            }
            let partnerInfo = UserInformation(data: data)
            completion(partnerInfo)
        }
    }
    
    func isExistUser(userId: String,completion: @escaping (Bool, UserInformation?) -> Void ) {
        let userInfoDocumentRef = getPartnerUserInfoDocumentRef(partnerId: userId)
        userInfoDocumentRef.getDocument { (snapshot, error) in
            guard let error = error else {
                guard let data = snapshot?.data() else {
                    return
                }
                let partnerInfo = UserInformation(data: data)
                completion(true, partnerInfo)
                return
            }
            completion(false, nil)
        }
    }
    
    func deleteUpdate() {
        let userInfoDocumentRef = getUserInfoDocumentRef()
        userInfoDocumentRef.updateData(["partnerId": "",
                                        "partnerName": "",
                                        "roomId": "",])
    }
}

extension UserInformationFirestoreRepository {
    func saveImage(image: UIImage, completion: @escaping ((_ imageUrl: String?)->Void)) {
        // まずは保存するところのパスをとる。
        let storageRef = Storage.storage().reference()
        // 被る確率を減らすために、名前に現在の時間をつける。
        // 100%被らないようにするのはハイコストだけど、99%はいける
        let currentTime = String(Int(floor(NSDate().timeIntervalSince1970 * 100000)))
        // 次はどんな名前で保存すればいいかな〜と考える
        // userのIDをつかえばいいのか？
        
        let metadata = StorageMetadata()
        // コンテンツのタイプを、アップロード時にfirebaseに教えてあげる。教えないと、写真として保存されない。
        // ダウンロードするときに写真として持ってこれない。
        // サーバーは、コンテンツタイプを理解して、ダウンロードするかを決める。（処理をどうするかを決める）
        metadata.contentType = "image/jpeg"
        //画像を非同期にアップロード
        let dataRef = storageRef.child("\(currentTime).jpg")
        // 画像をJpegにする関数。数字は圧縮率。0.5がバランスが取れている。らしい。
        let data = image.jpegData(compressionQuality: 0.5)
        // firebase で決まっている関数。metadataも一緒に送っているよ。
        dataRef.putData(data!, metadata: metadata) { (metadata, error) in
            // error で比較しないんだ。firebaseのドキュメント読めばいいんだよ
            guard let metadata = metadata else {
                completion(nil)
                return
            }
            // ここは特に意味ない。
            let size = metadata.size
            // ダウンロードURLを取得するよ。このURLを取れるようになったよ！！！
            dataRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(nil)
                    return
                }
                completion(downloadURL.absoluteString)
            }
        }
    }
}

