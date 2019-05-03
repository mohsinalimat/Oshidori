//
//  TimelineViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/11.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var timelineTableView: UITableView!
  
    let timelineService = TimelineService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timelineService.delegate = self
        
        timelineTableView.register (UINib(nibName: "TimelineMessageTableViewCellTableViewCell", bundle: nil),forCellReuseIdentifier:"TimelineMessageCell")
        
        // セルの高さを自動設定
        timelineTableView.estimatedRowHeight = 50 //予想のセルの高さ //入れないとワーニングが出る
        timelineTableView.rowHeight = UITableView.automaticDimension
        
        // timelineMessages の初期化
        timelineService.timelineMessagesRemove()
        // firestoreからデータを取って、テーブルビューに反映
        timelineService.loadTimelineMessage()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineService.getTimelineMessagesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineMessageCell", for: indexPath) as? TimelineMessageTableViewCell else {
            return UITableViewCell()
        }
        let message:RepresentationMessage = timelineService.getMessage(indexPathRow: indexPath.row)
        cell.setContentLabel(content: message.content ?? "")
        if let date = message.sentDate {
            let sentDate = convertDateToString(timestampDate: date as NSDate)
            cell.setSendDataLabel(sendDate: sentDate)
        }
        cell.setSenderId(senderId: message.senderId ?? "")
        cell.setContentTypeImage(contentType: message.contentType ?? "")
        cell.setCourageCountLabel(courageCount: message.courageCount ?? 0)
        cell.setSupportCountLabel(supportCount: message.supportCount ?? 0)
        return cell
    }
}
  
extension TimelineViewController: TimelineServiceDelegate {
    func loaded() {
        timelineTableView.reloadData()
    }
}
