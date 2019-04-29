//
//  UserDefault.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/3.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let messagesKey = "messages"
    
    // MARK: - Mock Messages
    
    func setMessages(count: Int) {
        set(count, forKey: "messages")
        synchronize()
    }
    
    func messagesCount() -> Int {
        if let value = object(forKey: "messages") as? Int {
            return value
        }
        return 20
    }
    
    static func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}
