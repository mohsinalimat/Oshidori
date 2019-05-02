//
//  UserInformation.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/16.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import PKHUD

class UserInformation {
    
    // シングルトン実装
    static var shared = UserInformation()
    
    var name: String = ""
    var birthday: Date?
    var partnerId: String = ""
    var partnerName: String = ""
    var roomId: String = ""
    var imageUrl: String = ""
    var created: Date?
    
    init() {}
 
    init(name: String, birthday: Date?, partnerId: String, roomId: String, created: Date, imageUrl: String) {
        self.name = name
        self.birthday = birthday
        self.partnerId = partnerId
        self.roomId = roomId
        self.created = created
        self.imageUrl = imageUrl
    }
    
    init(data: [String: Any]) {
        if let name = data["name"] as? String {
            self.name = name
        }
        if let birthday = data["birthday"] as? Date {
            self.birthday = birthday
        }
        
        if let partnerId = data["partnerId"] as? String {
            self.partnerId = partnerId
        }
        if let roomId = data["roomId"] as? String {
            self.roomId = roomId
        }
        if let created = data["created"] as? Date {
            self.created = created
        }
        if let imageUrl = data["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
    }

}

// firestorageに保存する用
extension UserInformation {
    var representation: [String : Any] {
        guard let birthday = birthday else {
            let rep: [String : Any] = [
                "name": name,
                "birthday": "",
                "partnerId": partnerId,
                "roomId": roomId,
                "created": created!,
                "imageUrl": imageUrl,
            ]
            return rep
        }
        let rep: [String : Any] = [
            "name": name,
            "birthday": birthday,
            "partnerId": partnerId,
            "roomId": roomId,
            "created": created!,
            "imageUrl": imageUrl,
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
        ]
        return rep
    }
}
