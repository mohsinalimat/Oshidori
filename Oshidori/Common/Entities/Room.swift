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
    var userName: String = ""
    var userImageUrl: String = ""
    
    var partnerId: String = ""
    var partnerName: String = ""
    var partnerImageUrl: String = ""
    
    init(roomId: String, userId: String, partnerId: String) {
        self.roomId = roomId
        self.userId = userId
        self.partnerId = partnerId
    }
    
    init (roomId: String, userId: String,userName: String,userImageUrl: String,
          partnerId: String, partnerName: String, partnerImageUrl: String) {
        self.roomId = roomId
        self.userId = userId
        self.userName = userName
        self.userImageUrl = userImageUrl
        self.partnerId = partnerId
        self.partnerName = partnerName
        self.partnerImageUrl = partnerImageUrl
    }
}

extension Room {
    var representation: [String : Any] {
        let rep: [String : Any] = [
            "roomId": roomId,
            "firstUser": userId,
            "firstUserName": userName,
            "firstUserImageUrl": userImageUrl,
            "secondUser": partnerId,
            "secondUserName": partnerName,
            "secondUserImageUrl": partnerImageUrl,
        ]
        return rep
    }
}
