//
//  UserInformation.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/16.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import PKHUD
import Firebase

class UserInformation {
    
    // シングルトン実装
    static var shared = UserInformation()
    
    var name: String = ""
    var FCMToken: String = ""
    var birthday: Date?
    var partnerId: String = ""
    var partnerName: String = ""
    var roomId: String = ""
    var imageUrl: String = ""
    var imageName: String = ""
    var created: Date?
    
    init() {}
 
    init(name: String, FCMToken: String, birthday: Date?, partnerId: String, partnerName: String, roomId: String, created: Date, imageUrl: String) {
        self.name = name
        self.FCMToken = FCMToken
        self.birthday = birthday
        self.partnerId = partnerId
        self.partnerName = partnerName
        self.roomId = roomId
        self.created = created
        self.imageUrl = imageUrl
    }
    
    init(name: String, FCMToken: String, birthday: Date?, partnerId: String, partnerName: String, roomId: String, created: Date, imageUrl: String, imageName: String) {
        self.name = name
        self.FCMToken = FCMToken
        self.birthday = birthday
        self.partnerId = partnerId
        self.partnerName = partnerName
        self.roomId = roomId
        self.created = created
        self.imageUrl = imageUrl
        self.imageName = imageName
    }
    
    init(data: [String: Any]) {
        if let name = data["name"] as? String {
            self.name = name
        }
        if let FCMToken = data["FCMToken"] as? String {
            self.FCMToken = FCMToken
        }
        if let birthday = data["birthday"] as? Timestamp {
            self.birthday = birthday.dateValue()
        }
        if let partnerId = data["partnerId"] as? String {
            self.partnerId = partnerId
        }
        if let partnerName = data["partnerName"] as? String {
            self.partnerName = partnerName
        }
        if let roomId = data["roomId"] as? String {
            self.roomId = roomId
        }
        if let created = data["created"] as? Timestamp {
            self.created = created.dateValue()
        }
        if let imageUrl = data["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        if let imageName = data["imageName"] as? String {
            self.imageName = imageName
        }
    }

}

// firestorageに保存する用
extension UserInformation {
    var representation: [String : Any] {
        guard let created = created else {
            if let birthday = birthday {
                let rep: [String : Any] = [
                    "name": name,
                    "FCMToken": FCMToken,
                    "birthday": birthday,
                    "partnerId": partnerId,
                    "partnerName": partnerName,
                    "roomId": roomId,
                    "created": "",
                    "imageUrl": imageUrl,
                    "imageName": imageName,
                ]
                return rep
            } else {
                let rep: [String : Any] = [
                    "name": name,
                    "FCMToken": FCMToken,
                    "birthday": "",
                    "partnerId": partnerId,
                    "partnerName": partnerName,
                    "roomId": roomId,
                    "created": "",
                    "imageUrl": imageUrl,
                    "imageName": imageName,
                ]
                return rep
            }
            
        }
        guard let birthday = birthday else {
            let rep: [String : Any] = [
                "name": name,
                "FCMToken": FCMToken,
                "birthday": "",
                "partnerId": partnerId,
                "partnerName": partnerName,
                "roomId": roomId,
                "created": created,
                "imageUrl": imageUrl,
                "imageName": imageName,
            ]
            return rep
        }
        let rep: [String : Any] = [
            "name": name,
            "FCMToken": FCMToken,
            "birthday": birthday,
            "partnerId": partnerId,
            "partnerName": partnerName,
            "roomId": roomId,
            "created": created,
            "imageUrl": imageUrl,
            "imageName": imageName,
        ]
        return rep
    }
}

// firestorageに保存する用
extension UserInformation {
    var editNameRepresentation: [String : Any] {
        let rep: [String : Any] = [
            "name": name,
        ]
        return rep
    }
}

extension UserInformation {
    var editBirthdayRepresentation: [String : Any] {
        guard let birthday = birthday else {
            let rep: [String : Any] = [
                "birthday": "",
            ]
            return rep
        }
        let rep: [String : Any] = [
            "birthday": birthday,
        ]
        return rep
    }
}

extension UserInformation {
    var editUserImageUrlRepresentation: [String : Any] {
        let rep: [String : Any] = [
            "userUrlImage": imageUrl,
            "imageName": imageName,
        ]
        return rep
    }
}
