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
        let reportRef = db.collection("reportMessages")
        guard let uid = User.shared.getUid() else {
            return
        }
        let rep: [String : Any] = [
            "reportSender" : uid,
            "reportContent": reportContent,
            "content"      : message.content ?? "",
            "senderId"     : message.senderId ?? "",
            "senderName"   : message.senderName ?? "",
            "sentDate"     : message.sentDate ?? "",
        ]
        reportRef.addDocument(data: rep)
    }
}
