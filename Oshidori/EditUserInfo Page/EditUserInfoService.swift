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
    
    func updateBirthday(birthday: Date) {
        rep.getUserInfo(completion: { (userInfo) in
            userInfo.birthday = birthday
            self.rep.update(userInfo, completion: {
                self.delegate?.updated()
            })
        })
    }
    
    func updateImage(imageUrl: String) {
        rep.getUserInfo(completion: { (userInfo) in
            userInfo.imageUrl = imageUrl
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
    
}