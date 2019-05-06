//
//  UserInfoService.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/24.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import UIKit

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
    
    func save (_ userInfo: UserInformation) {
        userInfoRep.save(userInfo) {
            self.delegate?.saved()
        }
    }
    
    func update () {
        guard User.shared.getUid() != nil else {
            debugPrint("更新できません")
            return
        }
        userInfoRep.getUserInfo { (UserInformation) in
            self.userInfoRep.update(UserInformation, completion: {
                debugPrint("更新完了")
            })
        }
    }
    
    func saveImage(image: UIImage?, completion: @escaping ((_ imageUrl: String?)->Void)){
        guard let image = image else {
            completion(nil)
            return
        }
        userInfoRep.saveImage(image: image) { (imageUrl) in
            guard let url = imageUrl else {
                return
            }
            EditUserInfoService.shared.updateImage(imageUrl: url)
            completion(imageUrl)
        }
    }
}




