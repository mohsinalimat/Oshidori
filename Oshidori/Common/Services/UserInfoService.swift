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
    
    private var UserInformationRepository = FirestoreUserInformationRepository()
    
    weak var delegate: UserInfoServiceDelegate?
    
    // タスクの追加
    func save (_ userInfo: UserInformation) {
        UserInformationRepository.save(userInfo) {
            self.delegate?.saved()
        }
    }
}



