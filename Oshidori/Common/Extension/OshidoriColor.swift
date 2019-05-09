//
//  UIColor.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/12.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import Foundation
import UIKit

class OshidoriColor: UIColor {
    
    // class修飾子は、overrideを利用できるため、primaryColorをこの画面だけ変更したいという意図を汲み取れるようになる。
    // 濃い緑を返す
    class var primary: UIColor {
        return rgbColor(rgbValue: 0x73C6B6)
    }
    
    // 薄いオレンジを返す
    class var secondary: UIColor {
        return rgbColor(rgbValue: 0xFFD6BA)
    }
    
    // 白っぽい灰色を返す
    class var background: UIColor {
        return rgbColor(rgbValue: 0xF0F0F0)
    }
    
    // 薄い緑を返す
    class var light: UIColor {
        return rgbColor(rgbValue: 0xE8F7F4)
    }
    
    // ほぼ黒に近い青を返す
    class var dark: UIColor {
        return rgbColor(rgbValue: 0x555B6E)
    }
    
    class var thanks: UIColor {
        return rgbColor(rgbValue: 0xFF64A5)
    }
    
    class var sorry: UIColor {
        return rgbColor(rgbValue: 0x1D88BB)
    }
    
    class var anone: UIColor {
        return rgbColor(rgbValue: 0xAE9D00)
    }
    
    // #FFFFFFのように色を指定できるようになる
    private class func rgbColor(rgbValue: UInt) -> UIColor{
        return UIColor(
            red:   CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >>  8) / 255.0,
            blue:  CGFloat( rgbValue & 0x0000FF)        / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
