//
//  QRcodeViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/15.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Firebase

class QRcodeViewController: UIViewController {
    
    @IBOutlet weak var QRcode: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

extension QRcodeViewController {
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
        let storyboard = UIStoryboard(name: "QRcodeRead", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "QRcodeReadStoryboard")
        self.navigationController?.pushViewController(VC, animated: false)
    }
}
    

