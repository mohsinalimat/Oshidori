////
////  PartnerSettingViewController.swift
////  Oshidori
////
////  Created by Tatsuya Yamamoto on 2019/5/6.
////  Copyright © 2019 山本竜也. All rights reserved.
////
//
//import UIKit
//
//class PartnerSettingViewController2: UIViewController {
//
//    @IBOutlet weak var tableView: UITableView!
//
//    var partnerName :String?
//    var partnerImageUrl :String?
//    var partnerFlag :Bool = false
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//
//        tableView.register(UINib(nibName: "PartnerImageCell", bundle: nil), forCellReuseIdentifier: PartnerImageCell.description())
//        tableView.register(UINib(nibName: "PartnerInfoCell", bundle: nil), forCellReuseIdentifier: PartnerInfoCell.description())
//        tableView.register(UINib(nibName: "AlertInfoCell", bundle: nil), forCellReuseIdentifier: AlertInfoCell.description())
//        tableView.register(UINib(nibName: "SettingButtonCell", bundle: nil), forCellReuseIdentifier: SettingButtonCell.description())
//        // 最後のセル以降にSeparatorを見せないようにする
//        tableView.tableFooterView = UIView()
//    }
//
//}
//
//extension PartnerSettingViewController: UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        if partnerFlag == true {
//            return 4
//        }
//        return 3
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        switch indexPath.section {
//        case 0:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: PartnerImageCell.description(), for: indexPath) as? PartnerImageCell else {
//                return UITableViewCell()
//            }
//            if let imageUrl = partnerImageUrl {
//                cell.imageUrl = imageUrl
//            }
//            return cell
//        case 1:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: PartnerInfoCell.description(), for: indexPath) as? PartnerInfoCell else {
//                return UITableViewCell()
//            }
//            cell.subTitle = "ニックネーム"
//            if partnerFlag == true {
//                if let name = partnerName {
//                    cell.name = name
//                }
//            } else {
//                cell.name = "未設定"
//            }
//            return cell
//        case 2:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingButtonCell.description(), for: indexPath) as? SettingButtonCell else {
//                return UITableViewCell()
//            }
//            if partnerFlag == true {
//                cell.cancelTitle = "解除する"
//            } else {
//                cell.makeTitle = "パートナーを紐付ける"
//            }
//            return cell
//        case 3:
//            if partnerFlag == false {
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: AlertInfoCell.description(), for: indexPath) as? AlertInfoCell else {
//                    return UITableViewCell()
//                }
//                return cell
//            }
//
//        default:
//            return UITableViewCell()
//        }
//        return UITableViewCell()
//    }
//}
//
//extension PartnerSettingViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        debugPrint(indexPath.section)
//        switch indexPath.section {
//        case 2:
//            if partnerFlag == false {
//                moveQRcodePage()
//            } else {
//                alertSelect("本当に解除しますか？", "※パートナーを解除すると全てのデータが削除されてしまいます。※データの修復はできませんので、解除は慎重にお願いいたします。") {
//                    let userService = UserInfoService()
//                    userService.deleteUserInfo(completion: {
//                        User.shared.logout()
//                        self.moveSelectRegisterOrLoginPage()
//                    })
//                }
//            }
//        default:
//            break
//        }
//    }
//}
