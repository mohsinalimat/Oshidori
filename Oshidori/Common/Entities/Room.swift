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
    
    init(data: [String: Any]) {
        if let roomId = data["roomId"] as? String {
            self.roomId = roomId
        }
        guard let uid = User.shared.getUid() else {
            return
        }
        guard let firstUserId = data["firstUserId"] as? String else {
            return
        }
        guard let secondUserId = data["secondUserId"] as? String else {
            return
        }
        if firstUserId == uid {
            
            self.userId = firstUserId
            if let firstUserName = data["firstUserName"] as? String {
                self.userName = firstUserName
            }
            if let firstUserImageUrl = data["firstUserImageUrl"] as? String{
                self.userImageUrl = firstUserImageUrl
            }
            
            self.partnerId = secondUserId
            if let secondUserName = data["secondUserName"] as? String {
                self.partnerName = secondUserName
            }
            if let secondUserImageUrl = data["secondUserImageUrl"] as? String{
                self.partnerImageUrl = secondUserImageUrl
            }
            
        } else {
            
            self.partnerId = firstUserId
            if let firstUserName = data["firstUserName"] as? String {
                self.partnerName = firstUserName
            }
            if let firstUserImageUrl = data["firstUserImageUrl"] as? String{
                self.partnerImageUrl = firstUserImageUrl
            }
            
            self.userId = secondUserId
            if let secondUserName = data["secondUserName"] as? String {
                self.userName = secondUserName
            }
            if let secondUserImageUrl = data["secondUserImageUrl"] as? String{
                self.userImageUrl = secondUserImageUrl
            }
            
        }
    }
}

extension Room {
    var representation: [String : Any] {
        let rep: [String : Any] = [
            "roomId": roomId,
            "firstUserId": userId,
            "firstUserName": userName,
            "firstUserImageUrl": userImageUrl,
            "secondUserId": partnerId,
            "secondUserName": partnerName,
            "secondUserImageUrl": partnerImageUrl,
        ]
        return rep
    }
}
