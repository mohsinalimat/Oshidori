//
//  ReportRepository.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/26.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import FirebaseFirestore

final class ReportRepository {
    
    private let db = Firestore.firestore()
    func save(reportContent:String, message:RepresentationMessage) {
        
        guard let uid = User.shared.getUid() else {
            return
        }
        let reportRef = db.collection("reportMessages").document(uid)
        let rep: [String : Any] = [
            "reportDate"   : Date(),
            "reportSender" : uid,
            "reportContent": reportContent,
            "content"      : message.content ?? "",
            "senderId"     : message.senderId ?? "",
            "senderName"   : message.senderName ?? "",
            "sentDate"     : message.sentDate ?? "",
        ]
        reportRef.setData(rep)
    }
}
