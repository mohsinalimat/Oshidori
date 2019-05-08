//
//  MessageRoomService.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/7.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import MessageKit
import Firebase

protocol MessageRoomServiceDelegate: class {
    func saved()
    func loaded()
    func firestoreUpdated()
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
    var tmpMessage: RepresentationMessage?
    
    weak var delegate: MessageRoomServiceDelegate?
    
    private var messageRoomListener: ListenerRegistration?
    
    deinit {
        messageRoomListener?.remove()
    }
}

extension MessageRoomService {
    func makeLisner(roomId: String, messageId: String) {
        guard let messageRoomCollectionRef = messageRoomRep.getRoomMessagesCollectionRef(roomId: roomId, messageId: messageId) else {
            return
        }
        messageRoomListener = messageRoomCollectionRef.order(by: "sentDate", descending: false).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for roomMessage updates: \(error?.localizedDescription ?? "No error")")
                return
            }
//            self.messageList.removeAll()
//            self.messages.removeAll()
            snapshot.documentChanges.forEach { change in
                let repMessage = RepresentationMessage(data: change.document.data())
                if self.tmpMessage?.messageId == repMessage.messageId {
                    return
                }
                self.messageList.append(repMessage)
                self.tmpMessage = repMessage
            }
            self.repToMessage()
            self.delegate?.firestoreUpdated()
            debugPrint("🌞")
        }
    }
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
                // Lestnerを作成しておく
                self.makeLisner(roomId: userInfo.roomId, messageId: messageId)
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
