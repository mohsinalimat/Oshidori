//
//  TimelineViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/11.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Accounts
import GoogleMobileAds

final class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak private var timelineTableView: UITableView!
  
    let timelineService = TimelineService.shared
    
    private let refreshCtl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timelineService.delegate = self
        timelineTableView.separatorStyle = .none
        
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
        // tableViewを選択不可にする
        timelineTableView.allowsSelection = false
    }
    
    override func viewDidLayoutSubviews(){
        //  広告インスタンス作成
        var admobView = GADBannerView()
        admobView = GADBannerView(adSize:kGADAdSizeBanner)
        
        //  広告位置設定
        let safeArea = self.view.safeAreaInsets.bottom
        admobView.frame.origin = CGPoint(x:0, y:self.view.frame.size.height - safeArea - admobView.frame.height)
        admobView.frame.size = CGSize(width:self.view.frame.width, height:admobView.frame.height)
        
        //  広告ID設定
        admobView.adUnitID = "ca-app-pub-7170969191214776/1140643009"
        
        //  広告表示
        admobView.rootViewController = self
        admobView.load(GADRequest())
        self.view.addSubview(admobView)
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
        cell.delegate = self
        cell.tag = indexPath.row
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

extension TimelineViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}

extension TimelineViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func setDZNEmptyDataDelegate() {
        timelineTableView.emptyDataSetSource = self
        timelineTableView.emptyDataSetDelegate = self
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        // now loadingとか欲しいかも
        return UIImage(named: "Timeline_null")
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
        timelineTableView.separatorStyle = .singleLine
    }
}

extension TimelineViewController: TimelineMessageTableViewCellDelegate {
    func reportButtonTapped(index: Int) {
        let messages = timelineService.getTimelineMessages()
        if messages.isEmpty {
            return
        }
        let VC = PresentReportViewController.instantiate()
        VC.delegate = self
        VC.reportMessage = messages[index]
        present(VC, animated: true, completion: nil)
    }
    
    func shareButtonTapped(index: Int) {
        let messages = timelineService.getTimelineMessages()
        if messages.isEmpty {
            return
        }
        guard let shareText = messages[index].content else {
            return
        }
        let text = shareText
        let activityItems = [text]
        debugPrint(shareText)
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.mail,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.markupAsPDF,
        ]
        activityVC.excludedActivityTypes = excludedActivityTypes
     
        // iPadのクラッシュを防ぐ
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        // UIActivityViewControllerを表示
        self.present(activityVC, animated: true, completion: nil)
    }
}

extension TimelineViewController: PresentReportViewControllerDelegate {
    func cancelButtonTapped() {
        
    }
    
    func reportButtonTapped(reportMessage: RepresentationMessage) {
        let VC = ReportViewController.instantiate()
        VC.reportMessage = reportMessage
        present(VC, animated: true, completion: nil)
    }
}
