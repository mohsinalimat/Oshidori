//
//  ReadQRcodeService.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/3.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation

protocol ReadQRcodeServiceDelegate: class {
    func updated()
    func gotInfo()
}

class ReadQRcodeService {
    
    static var shared = ReadQRcodeService()
    
    private var userInfoRep = UserInformationFirestoreRepository()
    private var roomRep = RoomFirestoreRepository()
    
    weak var delegate: ReadQRcodeServiceDelegate?
    
    var tmpUserInfo: UserInformation?
    var tmpPartnerInfo: UserInformation?
    
    func getUid() -> String {
        guard let uid = User.shared.getUid() else {
            return ""
        }
        return uid
    }
    
    func save(_ partnerId: String) {
        let uid = ReadQRcodeService.shared.getUid()
        let room = Room(roomId: "", userId: uid, partnerId: partnerId)
        ReadQRcodeService.shared.makeRoom(roomInfo: room)
    }
    
    func isExistPartner(partnerId: String, completion: @escaping (Bool, String?) -> Void) {
        userInfoRep.isExistUser(userId: partnerId) { (result, partnerInfo) in
            if let parnerInfo = partnerInfo {
                completion(result, partnerInfo?.name)
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
    
    func update() {
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
                
                self.delegate?.gotInfo()
            })
        })
    }
    
    
    
}
