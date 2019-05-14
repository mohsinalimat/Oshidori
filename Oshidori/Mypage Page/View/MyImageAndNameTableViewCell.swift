//
//  MyImageAndNameTableViewCell.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/29.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Nuke

protocol MyImageAndNameTableViewCellDelegate: class {
    func tapped()
}

class MyImageAndNameTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var moveEditUserInfoButton: UIButton!
    
    var delegate: MyImageAndNameTableViewCellDelegate?
    
    var url: URL?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        setButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUserImage(imageUrl :String?) {
        userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true
        userImage.layer.cornerRadius = userImage.frame.width / 2 // 3.0にしたら丸になった
        guard let strUrl = imageUrl else {
            return
        }
        if strUrl == "" {
            userImage.image = UIImage(named: "Oshidori_null")
        } else {
            url = URL(string: strUrl)
            if let url = url {
                Nuke.loadImage(with: url, into: userImage)
            }
        }
    }
    
    func setUserName(name: String) {
        userNameField.text = name
    }
    
    func setButton() {
        moveEditUserInfoButton.setTitleColor(OshidoriColor.primary, for: .normal)
    }
    
    @IBAction func didTapMoveEditUserInfoButton(_ sender: Any) {
        // moveUserEditPage()
        delegate?.tapped()
    }
}
