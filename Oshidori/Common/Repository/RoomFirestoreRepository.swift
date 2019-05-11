//
//  RoomFirestoreRepository.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/3.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import FirebaseFirestore

class RoomFirestoreRepository {
    let db = Firestore.firestore()
    
    private func getRoomColletionRef() -> CollectionReference {
        return db.collection("rooms")
    }
    
    func makeRoom(receiveRoomInfo: Room, completion: @escaping (Room)-> ()) {
        let roomRef = getRoomColletionRef().document()
        var roomInfo = receiveRoomInfo
        roomInfo.roomId = roomRef.documentID
        roomRef.setData(roomInfo.representation) { (error) in
            if let _ = error {
                return
            }
            completion(roomInfo)
        }
    }
    
    func updateRoom(updateRoom: Room, completion: @escaping () -> Void) {
        let roomDocumentRef = getRoomColletionRef().document(updateRoom.roomId)
        roomDocumentRef.updateData(updateRoom.representation) { (error) in
            if let _ = error {
                return
            }
            completion()
        }
    }
    
    func getRoomInfo(roomId: String, completion: @escaping (Room) -> Void) {
        let roomDocumentRef = getRoomColletionRef().document(roomId)
        roomDocumentRef.getDocument { (snapShot, error) in
            guard let data = snapShot?.data() else {
                return
            }
            let room = Room(data: data)
            completion(room)
        }
    }
    
    func getRoomMessageUserInfoRef(roomId: String, uid: String) -> CollectionReference {
        return getRoomColletionRef().document(roomId).collection("messageUserInfo").document(uid).collection("notRead")
    }
    
    func getRoomMessageUserInfo(roomId: String, uid: String, completion: @escaping ([String]) -> ()) {
        let roomMessageUserInfoRef = getRoomMessageUserInfoRef(roomId: roomId, uid: uid)
        roomMessageUserInfoRef.getDocuments { (querySnapShot, error) in
            var notReadMessageIds: [String] = []
            for document in querySnapShot!.documents {
                notReadMessageIds.append(document.documentID)
            }
            completion(notReadMessageIds)
        }
    }
    
    func addRoomMessageUserInfo(roomId: String, uid: String, messageId: String, completion: @escaping () -> ()) {
        let roomMessageUserInfoRef = getRoomMessageUserInfoRef(roomId: roomId, uid: uid)
        roomMessageUserInfoRef.document(messageId).setData(["messageId":messageId])
    }
    
    func delete(roomId: String, uid: String, messageId: String, completion: @escaping ([String]) -> ()) {
        let roomMessageUserInfoRef = getRoomMessageUserInfoRef(roomId: roomId, uid: uid)
        roomMessageUserInfoRef.document(messageId).delete()
    }
}
