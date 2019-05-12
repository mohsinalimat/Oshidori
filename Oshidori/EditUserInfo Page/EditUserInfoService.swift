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
    
    private var userInfoRep = UserInformationFirestoreRepository()
    
    private var roomRep = RoomFirestoreRepository()
    
    weak var delegate: EditUserInfoServiceDelegate?
    
    var editUserInfo: UserInformation?
    
    func updateName(name: String) {
        userInfoRep.getUserInfo(completion: { (userInfo) in
            userInfo.name = name
            self.userInfoRep.update(userInfo, completion: {
                
                if self.isExistPartner(userInfo: userInfo) {
                    // ここでルームを更新する
                    self.roomRep.getRoomInfo(roomId: userInfo.roomId, completion: { (room) in
                        var updateRoom = room
                        if userInfo.partnerId == updateRoom.partnerId {
                            updateRoom.userName = name
                        } else {
                            updateRoom.partnerName = name
                        }
                        self.roomRep.updateRoom(updateRoom: updateRoom, completion: {
                            self.delegate?.updated()
                        })
                    })
                } else {
                    self.delegate?.updated()
                }
            })
        })
    }
    
    func updateBirthday(birthday: Date) {
        userInfoRep.getUserInfo(completion: { (userInfo) in
            userInfo.birthday = birthday
            self.userInfoRep.update(userInfo, completion: {
                self.delegate?.updated()
            })
        })
    }
    
    func updateImage(imageUrl: String) {
        userInfoRep.getUserInfo(completion: { (userInfo) in
            userInfo.imageUrl = imageUrl
            self.userInfoRep.update(userInfo, completion: {
                
                if self.isExistPartner(userInfo: userInfo) {
                    // ここでルームを更新する
                    self.roomRep.getRoomInfo(roomId: userInfo.roomId, completion: { (room) in
                        var updateRoom = room
                        if userInfo.partnerId == updateRoom.partnerId {
                            updateRoom.userImageUrl = imageUrl
                        } else {
                            updateRoom.partnerImageUrl = imageUrl
                        }
                        self.roomRep.updateRoom(updateRoom: updateRoom, completion: {
                            self.delegate?.updated()
                        })
                    })
                } else {
                    self.delegate?.updated()
                }
            })
        })
    }
    
    func loadUserInfo() {
        userInfoRep.getUserInfo { (userInfo) in
            self.editUserInfo = userInfo
            self.delegate?.loaded()
        }
    }
    
    func isExistPartner(userInfo:UserInformation) -> Bool {
        if userInfo.roomId == "" {
            return false
        }
        return true
    }
    
}
