//
//  QRcodeReadViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/15.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import AVFoundation
import PKHUD

class ReadQRcodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // カメラやマイクの入出力を管理するオブジェクトを生成
    private let session = AVCaptureSession()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        setDelegate()
        
        checkAuthorization()
        // カメラやマイクのデバイスそのものを管理するオブジェクトを生成（ここではワイドアングルカメラ・ビデオ・背面カメラを指定）
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: .back)
        
        // ワイドアングルカメラ・ビデオ・背面カメラに該当するデバイスを取得
        let devices = discoverySession.devices
        
        //　該当するデバイスのうち最初に取得したものを利用する
        if let backCamera = devices.first {
            do {
                // QRコードの読み取りに背面カメラの映像を利用するための設定
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                
                if self.session.canAddInput(deviceInput) {
                    self.session.addInput(deviceInput)
                    
                    // 背面カメラの映像からQRコードを検出するための設定
                    let metadataOutput = AVCaptureMetadataOutput()
                    
                    if self.session.canAddOutput(metadataOutput) {
                        self.session.addOutput(metadataOutput)
                        
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                        
                        // 背面カメラの映像を画面に表示するためのレイヤーを生成
                        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        previewLayer.frame = self.view.bounds
                        previewLayer.videoGravity = .resizeAspectFill
                        self.view.layer.addSublayer(previewLayer)
                        
                        // 読み取り開始
                        self.session.startRunning()
                    }
                }
            } catch {
                // TODO:エラー処理
            }
        }
    }
    
    func checkAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if status == AVAuthorizationStatus.authorized {
            // アクセス許可あり
        } else if status == AVAuthorizationStatus.restricted {
            // ユーザー自身にカメラへのアクセスが許可されていない
            setAuthorization()
        } else if status == AVAuthorizationStatus.notDetermined {
            // まだアクセス許可を聞いていない
            setAuthorization()
        } else if status == AVAuthorizationStatus.denied {
            // アクセス許可されていない
            setAuthorization()
        }
    }
    
    func setAuthorization() {
        let title: String = "カメラのアクセスに失敗しました"
        let message: String = "カメラの許可がないため、パートナーのQRコードを読み取れません。「設定」からカメラの許可をお願いいたします！"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "設定", style: .default, handler: { (_) -> Void in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                return
            }
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            self.navigationController?.popViewController(animated: true)
        })
        let closeAction: UIAlertAction = UIAlertAction(title: "閉じる", style: .cancel, handler: {(_) -> Void in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(settingsAction)
        alert.addAction(closeAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // QRコードのデータかどうかの確認
            if metadata.type != .qr { continue }
            // QRコードの内容が空かどうかの確認
            if metadata.stringValue == nil { continue }
            // partnerIdを読み取る
            guard let partnerId = metadata.stringValue else {
                return
            }
            guard !(partnerId == User.shared.getUid()) else {
                alert("エラー","それは自分のQRコードだよ😱", nil)
                return
            }
            
            HUD.show(.progress)
            
            // TODO: partnerIdが存在するかどうかを確認しなきゃいけない
            PartnerSettingService.shared.isExistPartner(partnerId: partnerId) { (result, partnerName) in
                HUD.hide()
                if result == true {
                    if let name = partnerName {
                        // 読み取り終了
                        self.session.stopRunning()
                        self.alertSelect("確認", "\(name)さんをパートナーとして紐付けますか？", {
                            HUD.show(.progress)
                            
                            // ユーザ情報をsetする
                            PartnerSettingService.shared.save(partnerId)
                            
                        })
                        // 読み取り開始
                        self.session.startRunning()
                    }
                    
                } else {
                    self.alert("エラー", "ユーザが存在しません！正しいQRコードを読み込んでください！", nil)
                }
            }
        }
    }
}

extension ReadQRcodeViewController: PartnerSettingServiceDelegateDelegate {
    func gotInfo() {
        HUD.hide()
        PartnerSettingService.shared.updateUserInfo()
        HUD.show(.progress)
    }
    
    func updated() {
        HUD.hide()
        moveMessagePage()
    }
    
    func setDelegate() {
        PartnerSettingService.shared.delegate = self
    }
}

