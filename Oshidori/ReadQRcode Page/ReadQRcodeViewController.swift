//
//  QRcodeReadViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/15.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import PKHUD

class ReadQRcodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // カメラやマイクの入出力を管理するオブジェクトを生成
    private let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true

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
                print("Error occured while creating video device input: \(error)")
            }
        }
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
            // TODO: partnerIdが存在するかどうかを確認しなきゃいけない
            
            // 読み取り終了
            self.session.stopRunning()
            // ユーザ情報をsetする
            save(partnerId)
            moveMessagePage()
        }
    }
    
    // firebase 関連
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    private func getMyDocumentRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("users").document(uid).collection("info").document(uid)
    }
    private func getPartnerDocumentRef(partnerId: String) -> DocumentReference {
        return db.collection("users").document(partnerId).collection("info").document(partnerId)
    }
    private func getRoomCollectionRef() -> CollectionReference {
        guard let _ = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("rooms")
    }
    
    func save(_ partnerId: String) {
        HUD.show(.progress)
        print("Firestoreへセーブ")
        let myDocumentRef = getMyDocumentRef()
        let partnerDocumentRef = getPartnerDocumentRef(partnerId: partnerId)
        myDocumentRef.updateData(["partnerId": partnerId]){ err in
            if let err = err {
                debugPrint("Error updating document: \(err)")
                HUD.hide()
            } else {
                debugPrint("my partnerId updated!!!")
                
                guard let uid = User.shared.getUid() else {
                    return
                }
                
                partnerDocumentRef.updateData(["partnerId": uid]){ err in
                    if let err = err {
                        debugPrint("Error updating document: \(err)")
                        HUD.hide()
                    } else {
                        debugPrint("partnerId updated!!!")
                        
                        // roomIdを作成し、roomを作成し、userIDを登録している。
                        let roomRef = self.getRoomCollectionRef().document()
                        let roomId = roomRef.documentID
                        roomRef.setData([
                            "firstUser": uid ,
                            "secondUser": partnerId ,
                            "roomId" :  roomId ,
                        ]) { err in
                            if let err = err {
                                HUD.hide()
                                debugPrint("Error adding document: \(err)")
                            } else {
                                // roomIdをuserInfoに登録しにいっている。
                                myDocumentRef.updateData(["roomId": roomId]) { err in
                                    if let err = err {
                                        debugPrint("Error updating document: \(err)")
                                    }
                                    HUD.hide()
                                }
                                partnerDocumentRef.updateData(["roomId": roomId]) { err in
                                    if let err = err {
                                        debugPrint("Error updating document: \(err)")
                                    }
                                    HUD.hide()
                                    self.alert("成功", "パートナーができました！", nil)
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
}
