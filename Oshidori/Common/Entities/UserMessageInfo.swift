//
//  UserMessageInfo.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/30.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import PKHUD

class UserMessageInfo {
    
    // シングルトン実装
    static var shared = UserMessageInfo()
    
    var courageCount: Int?
    var supportCount: Int?
    var messageCount: Int?
    var messageIds: [String]?
    
    init() {}
    
    init(courageCount: Int, supportCount: Int, messageIds: [String], messageCount: Int) {
        self.courageCount = courageCount
        self.supportCount = supportCount
        self.messageIds = messageIds
        self.messageCount = messageCount
    }
    
    init(data: [String: Any]) {
        if let courageCount = data["courageCount"] as? Int {
            self.courageCount = courageCount
        }
        if let supportCount = data["supportCount"] as? Int {
            self.supportCount = supportCount
        }
        if let messageIds = data["messageIds"] as? [String] {
            self.messageIds = messageIds
        }
        if let messageCount = data["messageCount"] as? Int {
            self.messageCount = messageCount
        }
    }
    
}

// firestorageに保存する用
extension UserMessageInfo {
    var representation: [String : Any] {
        let rep: [String : Any] = [
            "courageCount": courageCount,
            "supportCount": supportCount,
            "messageIds": messageIds,
            "messageCount": messageCount,
        ]
        return rep
    }
}
