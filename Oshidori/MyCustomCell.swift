//
//  MyCustomCell.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/4.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import MessageKit

// Customize this collection view cell with data passed in from message, which is of type .custom
open class MyCustomCell: UICollectionViewCell {
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        self.contentView.backgroundColor = UIColor.red
    }
    
}
