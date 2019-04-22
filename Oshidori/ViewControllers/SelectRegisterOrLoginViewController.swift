//
//  SelectRegisterOrLoginViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/22.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

class SelectRegisterOrLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func didTopMoveUserCreateButton(_ sender: Any) {
        moveUserCreatePage()
    }
    
    @IBAction func didTopMoveLoginButton(_ sender: Any) {
        moveLoginPage()
    }
    

}
