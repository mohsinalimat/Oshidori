//
//  AppDescriptionViewController.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/11.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Eureka

class AppDescriptionViewController: FormViewController {
    
    let termsServiceUrl = "https://github.com/YamaTatsu10969/Oshidori_Documents/blob/master/TermsService.md"
    let privacyPolicyUrl = "https://github.com/YamaTatsu10969/Oshidori_Documents/blob/master/privacy_policy.md"
    let contactUrl = "https://forms.gle/KQw5YUYuo7wFZSR28"

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section() {
            // ヘッダーを非表示にする
            $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.header?.height = { CGFloat.leastNormalMagnitude }
            }
            <<< LabelRow(){ row in
                row.title = "バージョン情報"
                row.value = "1.0.0(1)"
            }
            <<< LabelRow(){ row in
                row.title = "利用規約"
                row.cellUpdate({ (LabelCell, LabelRow) in
                    LabelCell.accessoryType = .disclosureIndicator
                })
                row.onCellSelection({ (_, _) in
                    let tmpUrl = URL(string: self.termsServiceUrl)
                    guard let url = tmpUrl else {
                        return
                    }
                    if( UIApplication.shared.canOpenURL(url) ) {
                        UIApplication.shared.open(url)
                    }
                })
            }
            <<< LabelRow(){ row in
                row.title = "プライバシーポリシー"
                row.cellUpdate({ (LabelCell, LabelRow) in
                    LabelCell.accessoryType = .disclosureIndicator
                })
                row.onCellSelection({ (_, _) in
                    let tmpUrl = URL(string: self.privacyPolicyUrl)
                    guard let url = tmpUrl else {
                        return
                    }
                    if( UIApplication.shared.canOpenURL(url) ) {
                        UIApplication.shared.open(url)
                    }
                })
            }
            <<< LabelRow(){ row in
                row.title = "お問い合わせ"
                row.cellUpdate({ (LabelCell, LabelRow) in
                    LabelCell.accessoryType = .disclosureIndicator
                })
                row.onCellSelection({ (_, _) in
                    let tmpUrl = URL(string: self.contactUrl)
                    guard let url = tmpUrl else {
                        return
                    }
                    if( UIApplication.shared.canOpenURL(url) ) {
                        UIApplication.shared.open(url)
                    }
                })
        }
    }

}
