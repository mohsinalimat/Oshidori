//
//  QRcodeViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/15.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Firebase

class ShowQRcodeViewController: UIViewController {
    
    @IBOutlet weak var QRcode: UIImageView!
    
    var userInfoRep = UserInformationFirestoreRepository()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let uid = User.shared.getUid() else {
            return
        }
        
        // 値が変更されたら、移動するようにする
        let userInfoListener = db.collection("users").document(uid).collection("info").document(uid).addSnapshotListener { (querySnapshot, error) in
            
            guard let data = querySnapshot?.data() else {
                return
            }
            
            let userInfo = UserInformation(data: data)
            if userInfo.partnerId == "" {
                return
            } else {
                self.moveMessagePage()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        guard let uid = User.shared.getUid() else {
            return
        }
        guard let QRimage: UIImage  = generateQRCode(from: uid) else {
            return
        }
        QRcode.image = QRimage
    }
    
}

extension ShowQRcodeViewController {
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    @IBAction func moveQRcodeReadPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ReadQRcode", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "ReadQRcodeStoryboard")
        VC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(VC, animated: false)
    }
    
    @IBAction func moveSendEmailPageButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SendEmailViewController", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "SendEmailViewController")
        VC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(VC, animated: false)
    }
    
}
    

