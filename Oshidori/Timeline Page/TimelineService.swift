//
//  TimelineService.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/30.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation

class TimelineService: TimelineFirestoreRepository {
    
    static let shared = TimelineService()
    
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
    
}
