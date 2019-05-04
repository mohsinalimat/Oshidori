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
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            completion(roomInfo)
        }
    }
}
