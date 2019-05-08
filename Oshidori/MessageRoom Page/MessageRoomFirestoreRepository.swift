//
//  MessageRoomFirestoreRepository.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/7.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import Firebase


class MessageRoomFirestoreRepository {
    
    // firebase 関連
    private let db = Firestore.firestore()
    
    func getRoomMessagesCollectionRef(roomId: String, messageId: String) -> CollectionReference? {
        return db.collection("rooms").document(roomId).collection("messages").document(messageId).collection("messages")
    }
    
   
    private func getUserInformationRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            return db.collection("users").document("error")
        }
        return db.collection("users").document(uid).collection("info").document(uid)
    }
    
    func getUid() -> String {
        guard let uid = User.shared.getUid() else {
            return ""
        }
        return uid
    }
    
    func getUserInfo(completion: @escaping (UserInformation) -> Void) {
        // userInformaitonの初期化。情報を持ってくる
        getUserInformationRef().getDocument{ (document, error) in
            if let userInformation = document.flatMap({
                $0.data().flatMap({ (data) in
                    return UserInformation(data: data)
                })
            }) {
                // 上記で得た内容を保存する
                completion(userInformation)
            } else {
                // TODO: エラーへの対処
            }
        }
    }
    
    func getMessages(messageId: String, roomId: String, completion: @escaping (([RepresentationMessage]) -> Void )) {
        var messages: [RepresentationMessage] = []
        guard let collectionRef = getRoomMessagesCollectionRef(roomId: roomId, messageId: messageId) else {
            return
        }
        collectionRef.order(by: "sentDate", descending: false).getDocuments() { (querySnapshot, err) in
            // エラーだったらリターンするよ
            guard err == nil else { return }
            for document in querySnapshot!.documents {
                let message = RepresentationMessage(data: document.data())
                messages.append(message)
            }
            completion(messages)
        }
    }
    
    func save(message: Message,messageId: String, roomId: String) {
        guard let collectionRef = getRoomMessagesCollectionRef(roomId: roomId, messageId: messageId) else {
            return
        }
        collectionRef.addDocument(data: message.representation)
    }
    
}
