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
    var contentType: String
    // contentTypeの選択肢
    var contentTypes: [String] = ["ありがとう","ごめんね","あのね"]

    // kind をfireStorageに入れると落ちる. kind は型が異なるようだ。Stringとして
    // ただし、プロトコルにkind:MessageKind がいるので定義しておかなければエラーになる。
    var kind: MessageKind{
        return .text(content)
    }
    
    private init(content: String, sender: Sender, messageId: String, date: Date, contentType: String) {
        self.content = content
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.contentType = contentType
    }

    init(text: String, sender: Sender, messageId: String, date: Date, contentType: String) {
        self.init(content: text, sender: sender, messageId: messageId, date: date, contentType: contentType)
    }

}


// firestorageに保存する用
extension Message {
// 結局保存されているのはここだけなんか。
var representation: [String : Any] {
    let rep: [String : Any] = [
        "created": sentDate,
        "senderID": sender.id,
        "senderName": sender.displayName,
        "content": content,
        "contentType": contentType
    ]
    
    return rep
}

}

