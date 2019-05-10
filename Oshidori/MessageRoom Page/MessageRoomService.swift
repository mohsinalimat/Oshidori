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
import Nuke

protocol MessageRoomServiceDelegate: class {
    func saved()
    func loaded()
    func firestoreUpdated()
}

class MessageRoomService {
    
    static var shared = MessageRoomService()
    
    private var userInfoRep = UserInformationFirestoreRepository()
    
    private var messageRoomRep = MessageRoomFirestoreRepository()
    
    private var roomRep = RoomFirestoreRepository()
    
    var userInfo: UserInformation?
    var partnerInfo: UserInformation?
    var roomInfo: Room?
    var messageId :String?
    var messageList :[RepresentationMessage] = []
    var messages: [Message] = []
    var tmpMessage: RepresentationMessage?
    
    var lastDocument: DocumentSnapshot?
    
    weak var delegate: MessageRoomServiceDelegate?
    
    private var messageRoomListener: ListenerRegistration?
    
    var partnerImage:UIImageView?
    
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
                return
            }
            
            guard let lastSnapshot = snapshot.documents.last else {
                // The collection is empty
                return
            }
            if self.lastDocument == lastSnapshot {
                return
            }
            self.lastDocument = lastSnapshot
            snapshot.documents.forEach({ (documentSnapshot) in
                let repMessage = RepresentationMessage(data: documentSnapshot.data())
                self.messageList.append(repMessage)
            })
            self.repToMessage()
            self.delegate?.firestoreUpdated()
            
        }
    }
}

extension MessageRoomService {
    
    func save(message: Message) {
        guard let messageId = messageId, let roomId = roomInfo?.roomId else {
            return
        }
        messageRoomRep.save(message: message, messageId: messageId, roomId: roomId)
    }
    
    func getAllInfo(messageId: String, completion: @escaping () -> ()) {
        userInfoRep.getUserInfo { (userInfo) in
            self.userInfo = userInfo
            self.roomRep.getRoomInfo(roomId: userInfo.roomId, completion: { (room) in
                self.roomInfo = room
                if userInfo.partnerId == room.partnerId {
                    var imageUrl: URL?
                    imageUrl = URL(string: room.partnerImageUrl)
                    if let url = imageUrl {
                        let tmpImageView = UIImageView()
                        Nuke.loadImage(with: url, options: ImageLoadingOptions(
                            placeholder: UIImage(named: "Oshidori_null"),
                            transition: .fadeIn(duration: 0.33)
                            ), into: tmpImageView, progress: { (response, tmp , tmp1) in
                                
                        }, completion: { (response, error) in
                            self.partnerImage = tmpImageView
                            self.delegate?.loaded()
                        })
                    }
                } else {
                    var imageUrl: URL?
                    imageUrl = URL(string: room.userImageUrl)
                    if let url = imageUrl {
                        let tmpImageView = UIImageView()
                        Nuke.loadImage(with: url, into: tmpImageView)
                        self.partnerImage = tmpImageView
                    }
                }
                self.makeLisner(roomId: userInfo.roomId, messageId: messageId)
                completion()
            })
            self.userInfoRep.getPartnerUserInfo(partnerId: userInfo.partnerId, completion: { (partnerInfo) in
                self.partnerInfo = partnerInfo
                // Lestnerを作成しておく
//                self.makeLisner(roomId: userInfo.roomId, messageId: messageId)
//                completion()
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
    
    func removeAllMessages() {
        messageList.removeAll()
        messages.removeAll()
        tmpMessage = nil
        lastDocument = nil
    }
    
}
