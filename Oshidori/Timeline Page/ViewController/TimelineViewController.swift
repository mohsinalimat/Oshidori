//
//  TimelineViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/11.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var timelineTableView: UITableView!
  
    let timelineService = TimelineService.shared
    
    private let refreshCtl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timelineService.delegate = self
        
        setDZNEmptyDataDelegate()
        
        // 上のぐるぐるの実装
        timelineTableView.refreshControl = refreshCtl
        refreshCtl.tintColor = OshidoriColor.primary
        refreshCtl.addTarget(self, action: #selector(refreshTimeline), for: .valueChanged)
        
        timelineTableView.register (UINib(nibName: "TimelineMessageTableViewCellTableViewCell", bundle: nil),forCellReuseIdentifier:"TimelineMessageCell")
        
        // セルの高さを自動設定
        timelineTableView.estimatedRowHeight = 50 //予想のセルの高さ //入れないとワーニングが出る
        timelineTableView.rowHeight = UITableView.automaticDimension
        
        // timelineMessages の初期化
        timelineService.timelineMessagesRemove() {}
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
        // エラーを制御
        if timelineService.getTimelineMessagesCount() == 0 {
            return UITableViewCell()
        }
        let message:RepresentationMessage = timelineService.getMessage(indexPathRow: indexPath.row)
        cell.setContentLabel(content: message.content ?? "")
        if let date = message.sentDate {
            let sentDate = convertDateToString(timestampDate: date as NSDate)
            cell.setSendDataLabel(sendDate: sentDate)
        }
        cell.setSenderId(senderId: message.senderId ?? "")
        cell.setMessageId(messageId: message.messageId ?? "")
        cell.setContentType(contentType: message.contentType ?? "")
        cell.setCourageCountLabel(courageCount: message.courageCount ?? 0)
        cell.setSupportCountLabel(supportCount: message.supportCount ?? 0)
        cell.setIsCourageTapped(isTapped: message.isCourageTapped)
        cell.setIsSupportTapped(isTapped: message.isSupportTapped)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    // 下から５件くらいになったらリフレッシュ
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0)-5, section: 0)) != nil else {
            return
        }
        // ここでリフレッシュのメソッドを呼ぶ
        timelineService.loadTimelineMessage()
    }
}

extension TimelineViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func setDZNEmptyDataDelegate() {
        timelineTableView.emptyDataSetSource = self
        timelineTableView.emptyDataSetDelegate = self
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        // now loadingとか欲しいかも
        return UIImage(named: "Oshidori_null")
    }
    
}

extension TimelineViewController {
    @objc func refreshTimeline() {
        timelineService.refreshTimeline()
        self.refreshCtl.endRefreshing()
    }
}
  
extension TimelineViewController: TimelineServiceDelegate {
    func loaded() {
        timelineTableView.reloadData()
    }
}
