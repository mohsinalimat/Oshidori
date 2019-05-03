//
//  MypageService.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/1.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation

protocol MypageServiceDelegate:class {
    func gotUserMessageInfo()
    func gotUserInfo()
    func loaded()
}

class MypageService {
    
    static var shared = MypageService()
    
    private var mypageFirestoreRepository = UserMessageInfoFirestoreRepository()
    
    private var userMessageInfo: UserMessageInfo?
    
    private var userInfoRep = UserInformationFirestoreRepository()
    
    var userInfo: UserInformation?

    
    weak var delegate: MypageServiceDelegate?

    func getUserMessageInfo(uid: String) {
        mypageFirestoreRepository.getUserMessageInfo(uid: uid) { (userMessageInfo) in
            self.userMessageInfo = userMessageInfo
            self.delegate?.gotUserMessageInfo()
        }
    }
    
    func getCourageCount() -> String {
        guard let intCount = userMessageInfo?.courageCount else {
            return "0"
        }
        let strCount = String(intCount)
        return strCount
    }
    
    func getSupportCount() -> String {
        guard let intCount = userMessageInfo?.supportCount else {
            return "0"
        }
        let strCount = String(intCount)
        return strCount
    }
    
    func getMessageCount() -> String {
        guard let intCount = userMessageInfo?.messageCount else {
            return "0"
        }
        let strCount = String(intCount)
        return strCount
    }
    
}

extension MypageService {
    
    func getUserInfo() {
        userInfoRep.getUserInfo { (receivedUserInfo) in
            self.userInfo = receivedUserInfo
            self.delegate?.gotUserInfo()
        }
    }
}

