//
//  TabBarController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/12.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // アイコンの色
        UITabBar.appearance().tintColor = OshidoriColor.dark
        // 背景色
        UITabBar.appearance().barTintColor = OshidoriColor.light
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
