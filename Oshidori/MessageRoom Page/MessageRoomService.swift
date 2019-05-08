//
//  MessageRoomService.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/7.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import MessageKit

protocol MessageRoomServiceDelegate: class {
    func saved()
    func loaded()
}

class MessageRoomService {
    
    static var shared = MessageRoomService()
    
    private var userInfoRep = UserInformationFirestoreRepository()
    
    private var messageRoomRep = MessageRoomFirestoreRepository()
    
    var userInfo: UserInformation?
    var partnerInfo: UserInformation?
    var room: Room?
    var messageId :String?
    var messageList :[RepresentationMessage] = []
    var messages: [Message] = []
    
    weak var delegate: MessageRoomServiceDelegate?
}

extension MessageRoomService {
    
    func save(message: Message) {
        guard let messageId = messageId, let roomId = room?.roomId else {
            return
        }
        messageRoomRep.save(message: message, messageId: messageId, roomId: roomId)
    }
    
    func getAllInfo(messageId: String, completion: @escaping () -> ()) {
        userInfoRep.getUserInfo { (userInfo) in
            self.userInfo = userInfo
            self.userInfoRep.getPartnerUserInfo(partnerId: userInfo.partnerId, completion: { (partnerInfo) in
                self.partnerInfo = partnerInfo
                self.room = Room(roomId: userInfo.roomId, userId: partnerInfo.partnerId, partnerId: userInfo.partnerId)
                self.messageRoomRep.getMessages(messageId: messageId, roomId: userInfo.roomId) { (messages) in
                    self.messageList = messages
                    self.repToMessage()
                }
                completion()
            })
        }
    }
    
    func getUid() -> String {
        return messageRoomRep.getUid()
    }
    
    func repToMessage() {
        for message in messageList {
            convertMessage(repMessage: message)
        }
    }
    
    func convertMessage(repMessage: RepresentationMessage) {
        
        guard let repContent = repMessage.content else {
            return
        }
        guard let senderName = repMessage.senderName else {
            return
        }
        guard let senderId = repMessage.senderId else {
            return
        }
        let repSender  = Sender(senderId: senderId, displayName: senderName)
        guard let repMessageId = repMessage.messageId else {
            return
        }
        guard let repSentDate = repMessage.sentDate else {
           return
        }
        let message = Message(text: repContent, sender: repSender, messageId: repMessageId, date: repSentDate)
        messages.append(message)
    }
    
}
