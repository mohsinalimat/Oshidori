//
//  ReportedViewController.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/26.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class ReportedViewController: UIViewController {

    @IBOutlet weak var appriciateLabel: UILabel!
    @IBOutlet weak var movePrivacyPolicyPageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillLayoutSubviews() {
        setup()
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        let tmpUrl = URL(string: AppDescriptionViewController.privacyPolicyUrl)
        guard let url = tmpUrl else {
            return
        }
        if( UIApplication.shared.canOpenURL(url) ) {
            UIApplication.shared.open(url)
        }
    }
    
}

extension ReportedViewController {
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
        navItem.rightBarButtonItem = UIBarButtonItem(title: "完了", style: UIBarButtonItem.Style.done, target: self, action:#selector(self.returnView))
        navBar.pushItem(navItem, animated: true)
        self.view.addSubview(navBar)
        
        //navigationBarの背景のサイズと位置を調整
        navigationView.frame.origin = self.view.safeAreaLayoutGuide.owningView!.frame.origin
        navigationView.frame.size = CGSize(width: self.view.safeAreaLayoutGuide.owningView!.frame.width, height: navBar.frame.origin.y + navBar.frame.height)
    }
    
    @objc private func returnView(){
        guard let previousVC = self.presentingViewController as? ReportViewController else { return }
        previousVC.doneReported()
        previousVC.dismiss(animated: true)
    }
}
