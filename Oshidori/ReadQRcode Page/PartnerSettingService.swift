//
//  ReadQRcodeService.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/3.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation

protocol PartnerSettingServiceDelegateDelegate: class {
    func updated()
    func gotInfo()
}

class PartnerSettingService {
    
    static var shared = PartnerSettingService()
    
    private var userInfoRep = UserInformationFirestoreRepository()
    private var roomRep = RoomFirestoreRepository()
    
    weak var delegate: PartnerSettingServiceDelegateDelegate?
    
    var tmpUserInfo: UserInformation?
    var tmpPartnerInfo: UserInformation?
    
    func getUid() -> String? {
        guard let uid = User.shared.getUid() else {
            return nil
        }
        return uid
    }
    
    func save(_ partnerId: String) {
        guard let uid = PartnerSettingService.shared.getUid() else {
            return
        }
        let room = Room(roomId: "", userId: uid, partnerId: partnerId)
        PartnerSettingService.shared.makeRoom(roomInfo: room)
    }
    
    func isExistPartner(partnerId: String, completion: @escaping (Bool, String?) -> Void) {
        userInfoRep.isExistUser(userId: partnerId) { (result, partnerInfo) in
            guard let uid = self.getUid() else {
                return
            }
            if uid == partnerId {
                completion(result, nil)
            }
            if let partner = partnerInfo {
                completion(result, partner.name)
            } else {
                completion(result, nil)
            }
        }
    }
    
    func makeRoom(roomInfo :Room) {
        roomRep.makeRoom(receiveRoomInfo: roomInfo) { (room) in
            self.getBouthUserInfo(room: room)
        }
    }
    
    func updateUserInfo() {
        guard let userInfo = tmpUserInfo , let partnerInfo = tmpPartnerInfo else {
            return
        }
        userInfoRep.update(userInfo) {
            self.userInfoRep.updatePartnerInfo(partnerInfo, partnerId: userInfo.partnerId ){
                self.delegate?.updated()
            }
        }
    }
    
    func getBouthUserInfo(room: Room) {
        self.userInfoRep.getUserInfo(completion: { (userInformation) in
            self.userInfoRep.getPartnerUserInfo(partnerId: room.partnerId, completion: { (partnerInformation) in
                
                self.tmpUserInfo = userInformation
                self.tmpPartnerInfo = partnerInformation
                
                guard let userInfo = self.tmpUserInfo , let partnerInfo = self.tmpPartnerInfo else {
                    return
                }
                
                userInfo.partnerName = partnerInformation.name
                partnerInfo.partnerName = userInformation.name
                
                userInfo.partnerId = room.partnerId
                partnerInfo.partnerId = room.userId
                
                userInfo.roomId = room.roomId
                partnerInfo.roomId = room.roomId
                
                self.tmpUserInfo = userInfo
                self.tmpPartnerInfo = partnerInfo
                
                let updateRoom = Room(roomId: room.roomId, userId: room.userId, userName: userInfo.name,
                                      userImageUrl: userInfo.imageUrl, partnerId: room.partnerId,
                                      partnerName: partnerInfo.name, partnerImageUrl: partnerInfo.imageUrl)
                debugPrint(updateRoom)
                self.updateRoomInfo(updateRoom: updateRoom) {
                    
                }
                self.delegate?.gotInfo()
            })
        })
    }
    
    func updateRoomInfo(updateRoom: Room, completion: @escaping () ->Void) {
        roomRep.updateRoom(updateRoom: updateRoom) {
            completion()
        }
    }
    
    
    
}
