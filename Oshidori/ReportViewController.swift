//
//  ReportViewController.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/26.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {
    
    var reportMessage: RepresentationMessage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setup()
    }
    
    func setup() {
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
    
    @objc func returnView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
