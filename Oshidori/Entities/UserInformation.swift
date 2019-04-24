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
    
    var name: String = ""
    var birthday: Date?
    var partnerId: String = ""
     var roomId: String = ""
    var created: Date?
    
    init() {}
 
    init(name: String, birthday: Date, partnerId: String, roomId: String, created: Date) {
        self.name = name
        self.birthday = birthday
        self.partnerId = partnerId
        self.roomId = roomId
        self.created = created
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
    }

}

// firestorageに保存する用
extension UserInformation {
    var representation: [String : Any] {
        
        let rep: [String : Any] = [
            "name": name,
            "birthday": birthday!,
            "partnerId": partnerId,
            "roomId": roomId,
            "created": created!,
        ]
        return rep
    }
}

