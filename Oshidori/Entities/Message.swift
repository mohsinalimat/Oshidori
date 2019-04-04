//
//  Message.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/3.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import MessageKit

struct Message: MessageType {
    
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var content: String
    var kind: MessageKind{
            return .text(content)
    }
    
    private init(content: String, sender: Sender, messageId: String, date: Date) {
        self.content = content
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
//
//    init(custom: Any?, sender: Sender, messageId: String, date: Date) {
//        self.init(kind: .custom(custom), sender: sender, messageId: messageId, date: date)
//    }
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(content: text, sender: sender, messageId: messageId, date: date)
    }
    
//    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date) {
//        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
//    }
//
//    init(emoji: String, sender: Sender, messageId: String, date: Date) {
//        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date)
//    }
    
}


// firestorageに保存する用
extension Message {
// 結局保存されているのはここだけなんか。
var representation: [String : Any] {
    let rep: [String : Any] = [
        "created": sentDate,
        "senderID": sender.id,
        "senderName": sender.displayName,
        "content": content
    ]
    
    return rep
}

}

