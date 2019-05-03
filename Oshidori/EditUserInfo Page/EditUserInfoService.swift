//
//  EditUserInfoService.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/2.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation

protocol EditUserInfoServiceDelegate: class {
    func updated()
    func loaded()
}

class EditUserInfoService {
    
    static var shared = EditUserInfoService()
    
    private var rep = UserInformationFirestoreRepository()
    
    weak var delegate: EditUserInfoServiceDelegate?
    
    var editUserInfo: UserInformation?
    
    func updateName(name: String) {
        rep.getUserInfo(completion: { (userInfo) in
            userInfo.name = name
            self.rep.update(userInfo, completion: {
                self.delegate?.updated()
            })
        })
    }
    
    func loadUserInfo() {
        rep.getUserInfo { (userInfo) in
            self.editUserInfo = userInfo
            self.delegate?.loaded()
        }
    }
    
    // 流れは、saveを分けることかな〜。saveName()とかsaveBirthday()とか。
    
}
