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
}
