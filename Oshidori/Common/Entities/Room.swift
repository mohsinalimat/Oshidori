//
//  Room.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/3.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation

struct Room {
    var roomId: String    = ""
    var userId: String    = ""
    var partnerId: String = ""
    
    init(roomId: String, userId: String, partnerId: String) {
        self.roomId = roomId
        self.userId = userId
        self.partnerId = partnerId
    }
}

extension Room {
    var representation: [String : Any] {
        let rep: [String : Any] = [
            "roomId": roomId,
            "firstUser": userId,
            "secondUser": partnerId,
        ]
        return rep
    }
}
