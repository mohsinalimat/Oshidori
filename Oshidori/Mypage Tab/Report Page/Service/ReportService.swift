//
//  ReportService.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/26.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation

final class ReportService {
    let rep = ReportRepository()
    
    func report(reportContent: String, message: RepresentationMessage) {
        rep.save(reportContent: reportContent, message: message)
    }
}
