//
//  MyImageAndNameTableViewCell.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/29.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Nuke
import TextFieldEffects

class MyImageAndNameTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameField: HoshiTextField!
    @IBOutlet weak var userImage: UIImageView!
    var url :URL?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUserImage(imageUrl :String?) {
        if let strUrl = imageUrl {
            url = URL(string: strUrl)
            if let url = url {
                Nuke.loadImage(with: url, into: userImage)
            }
            // Nuke.loadImage(with: URL(string: url) ?? default value, into: userImage)
        } else {
            userImage.image = UIImage(named: "Oshidori_null")
        }
        userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true
        userImage.layer.cornerRadius = self.frame.height / 3.0 // 3.0にしたら丸になった
    }
    
    func setUserName(name: String) {
        userNameField.text = name
    }
    
}
