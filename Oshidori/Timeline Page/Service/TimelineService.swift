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
    
    private var keepLastDate: Date?
    
    func updateCourageCountForMessage(messageId: String) {
        timelineMessageRep.updateCourageCount(messageId: messageId)
        
        for (index, message) in timelineMessages.enumerated() {
            if message.messageId == messageId {
                timelineMessages[index].isCourageTapped = true
            }
        }
    }
    
    func updateSupportCountForMessage(messageId: String) {
        timelineMessageRep.updateSupportCount(messageId: messageId)
        
        for (index, message) in timelineMessages.enumerated() {
            if message.messageId == messageId {
                timelineMessages[index].isSupportTapped = true
            }
        }
    }
    
    func updateCourageCountForUser(uid: String) {
        userMessageInfoFirestoreRep.updateCourageCount(uid: uid)
    }
    
    func updateSupportCountForUser(uid: String) {
        userMessageInfoFirestoreRep.updateSupportCount(uid: uid)
    }
    
    func loadTimelineMessage() {
        guard  let lastDate = keepLastDate else {
            let now = Date()
            timelineMessageRep.loadTimelineMessage(lastDate: now) { (messages,lastDate)  in
                self.timelineMessages = messages
                self.keepLastDate = lastDate
                self.delegate?.loaded()
            }
            return
        }
        timelineMessageRep.loadTimelineMessage(lastDate: lastDate) { (messages,lastDate) in
            if self.keepLastDate == lastDate {
                return
            }
            for message in messages {
                self.timelineMessages.append(message)
            }
            self.keepLastDate = lastDate
            self.delegate?.loaded()
        }
    }
    
    func timelineMessagesRemove(completion:@escaping ()-> Void) {
        timelineMessages.removeAll()
        keepLastDate = nil
        completion()
    }
    
    func getTimelineMessagesCount() -> Int {
        return timelineMessages.count
    }
    
    func getMessage(indexPathRow: Int) -> RepresentationMessage {
        return timelineMessages[indexPathRow]
    }
    
    func refreshTimeline() {
        timelineMessagesRemove {
            self.loadTimelineMessage()
        }
    }
    
    
}
