//
//  TimelineService.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/30.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation

protocol TimelineServiceDelegate: class {
    func loaded()
}

class TimelineService {
    
    static let shared = TimelineService()
    
    weak var delegate:TimelineServiceDelegate?
    
    private var timelineMessages: [RepresentationMessage] = []
    
    private let timelineMessageRep = TimelineFirestoreRepository()
    
    private let userMessageInfoFirestoreRep = UserMessageInfoFirestoreRepository()
    
    func updateCourageCountForMessage(messageId: String) {
        timelineMessageRep.updateCourageCount(messageId: messageId)
    }
    
    func updateSupportCountForMessage(messageId: String) {
        timelineMessageRep.updateSupportCount(messageId: messageId)
    }
    
    func updateCourageCountForUser(uid: String) {
        userMessageInfoFirestoreRep.updateCourageCount(uid: uid)
    }
    
    func updateSupportCountForUser(uid: String) {
        userMessageInfoFirestoreRep.updateSupportCount(uid: uid)
    }
    
    func loadTimelineMessage() {
        timelineMessageRep.loadTimelineMessage { (messages) in
            self.timelineMessages = messages
            self.delegate?.loaded()
        }
    }
    
    func timelineMessagesRemove() {
        timelineMessages.removeAll()
    }
    
    func getTimelineMessagesCount() -> Int {
        return timelineMessages.count
    }
    
    func getMessage(indexPathRow: Int) -> RepresentationMessage {
        return timelineMessages[indexPathRow]
    }
    
    
    
}