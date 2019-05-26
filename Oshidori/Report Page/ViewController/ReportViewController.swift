//
//  ReportViewController.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/26.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

final class ReportViewController: UIViewController {
    
    var reportMessage: RepresentationMessage?
    
    @IBOutlet weak var tableView: UITableView!
    
    private let reportContent = ["成人向けアダルトコンテンツ","違法な製品、サービス","冒涜","政治関連の広告や社会問題広告など","その他"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setup()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SubTitleCell", bundle: nil), forCellReuseIdentifier: SubTitleCell.description())
        tableView.tableFooterView = UIView()
        let edgeInsets = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        tableView.contentInset = edgeInsets
        tableView.scrollIndicatorInsets = edgeInsets
    }
}

extension ReportViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return reportContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SubTitleCell.description(), for: indexPath) as? SubTitleCell else {
                return UITableViewCell()
            }
            cell.title = "問題の詳細をお知らせください。\nこのメッセージにどのような問題がありましたか？"
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = reportContent[indexPath.row]
            return cell
        }
    }
}

extension ReportViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            return
        }
        let reportService = ReportService()
        guard let message = reportMessage else {
            return
        }
        // reportService.report(reportContent: reportContent[indexPath.row], message: message)
        let VC = ReportedViewController.instantiate()
        self.present(VC, animated: true)
    }
}

extension ReportViewController {
    private func setup() {
        // TODO: たぶん正攻法じゃないから要変更
        
        let navigationView = UIView()
        self.view.addSubview(navigationView)
        
        let navBar = UINavigationBar()
        navBar.barTintColor = OshidoriColor.dark
        navigationView.backgroundColor = OshidoriColor.dark
        
        navBar.tintColor = OshidoriColor.background
        navBar.titleTextAttributes = [.foregroundColor: OshidoriColor.background]
        
        navBar.frame.origin = self.view.safeAreaLayoutGuide.layoutFrame.origin
        navBar.frame.size = CGSize(width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: 44)
        let navItem : UINavigationItem = UINavigationItem(title: "問題を報告する")
        
        //ナビゲーションバー右のボタンを設定
        navItem.rightBarButtonItem = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItem.Style.plain, target: self, action:#selector(self.returnView))
        navBar.pushItem(navItem, animated: true)
        self.view.addSubview(navBar)
        
        //navigationBarの背景のサイズと位置を調整
        navigationView.frame.origin = self.view.safeAreaLayoutGuide.owningView!.frame.origin
        navigationView.frame.size = CGSize(width: self.view.safeAreaLayoutGuide.owningView!.frame.width, height: navBar.frame.origin.y + navBar.frame.height)
    }
    
    @objc func returnView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneReported() {
        self.dismiss(animated: false, completion: nil)
    }
}

