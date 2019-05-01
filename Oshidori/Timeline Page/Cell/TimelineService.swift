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
    
    private let rep = TimelineFirestoreRepository()
    
    func updateCourageCountForMessage(messageId: String) {
        rep.updateCourageCount(messageId: messageId)
    }
    
    func updateSupportCountForMessage(messageId: String) {
        rep.updateSupportCount(messageId: messageId)
    }
    
    
    
}
