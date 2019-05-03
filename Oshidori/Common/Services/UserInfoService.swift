//
//  UserInfoService.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/24.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation

protocol UserInfoServiceDelegate: class {
    func saved()
    func loaded()
}

class UserInfoService {
    
    static var shared = UserInfoService()
    
    private var userInfoRep = UserInformationFirestoreRepository()
    
    weak var delegate: UserInfoServiceDelegate?
    
    // TODO: ここは切り分けたほうがいい。。。時間がある時にでも。
    var userInfo: UserInformation?
    var partnerInfo: UserInformation?
    
    // タスクの追加
    func save (_ userInfo: UserInformation) {
        userInfoRep.save(userInfo) {
            self.delegate?.saved()
        }
    }
    
    func update (_ userInfo: UserInformation) {
        userInfoRep.getUserInfo { (UserInformation) in
            
        }
    }
    
}



