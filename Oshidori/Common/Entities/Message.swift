//
//  Message.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/3.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import MessageKit
import Firebase

struct Message: MessageType {
    
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var content: String
    var contentType: String?
    
    
    var courageCount: Int?
    var supportCount: Int?
    
    // contentTypeの選択肢
    var contentTypes: [String] = ["ありがとう","ごめんね","あのね"]

    // kind をfireStorageに入れると落ちる. kind は型が異なるようだ。Stringとして
    // ただし、プロトコルにkind:MessageKind がいるので定義しておかなければエラーになる。
    var kind: MessageKind{
        return .text(content)
    }
    
    init(content: String, sender: Sender, messageId: String,
                 date: Date, contentType: String, courageCount: Int, supportCount: Int) {
        self.content = content
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.contentType = contentType
        self.courageCount = courageCount
        self.supportCount = supportCount
    }
    

//    init(content: String, sender: Sender, messageId: String, date: Date, contentType: String,
//         courageCount: Int, supportCount: Int) {
//        self.init(content: content, sender: sender, messageId: messageId, date: date,
//                  contentType: contentType, courageCount: courageCount, supportCount: supportCount)
//    }
    
    // おしどり用
    private init(content: String, sender: Sender, messageId: String, date: Date) {
        self.content = content
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    // おしどり用
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(content: text, sender: sender, messageId: messageId, date: date)
    }
    
    // エラー回避のために作成。contentTypeがnilだった時のため
    func getContentType() -> String{
        guard let stringContentType = contentType else {
            return ""
        }
        return stringContentType
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
            "contentType": getContentType(),
            "courageCount" : courageCount,
            "supportCount" : supportCount,
        ]
        return rep
    }
}

extension Message {
    var editCourageCountRepresentation: [String : Any] {
        let rep: [String : Any] = [
            "courageCount": courageCount,
        ]
        return rep
    }
}

extension UserInformation {
    var editsupportCountRepresentation: [String : Any] {
        let rep: [String : Any] = [
            "supportCount": supportCount,
        ]
        return rep
    }
}


