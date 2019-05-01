//
//  RepresentationMessage.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/1.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation

struct RepresentationMessage {
    
    var content: String?
    var senderId: String?
    var messageId: String?
    var sentDate: Date?
    var contentType: String?
    var courageCount: Int?
    var supportCount: Int?
    
    init(content: String, senderId: String, messageId: String,
         sentDate: Date, contentType: String, courageCount: Int, supportCount: Int) {
        self.content = content
        self.senderId = senderId
        self.messageId = messageId
        self.sentDate = sentDate
        self.contentType = contentType
        self.courageCount = courageCount
        self.supportCount = supportCount
    }
    
    init(data: [String: Any]) {
        if let content = data["content"] as? String {
            self.content = content
        }
        if let senderId = data["senderId"] as? String {
            self.senderId = senderId
        }
        if let messageId = data["messageId"] as? String{
            self.messageId = messageId
        }
        if let sentDate = data["sentDate"] as? Date {
            self.sentDate = sentDate
        }
        if let contentType = data["contentType"] as? String {
            self.contentType = contentType
        }
        if let courageCount = data["courageCount"] as? Int {
            self.courageCount = courageCount
        }
        if let supportCount = data["supportCount"] as? Int {
            self.supportCount = supportCount
        }
    }
}
