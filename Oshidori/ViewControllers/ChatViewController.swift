//
//  ChatViewController.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/4/3.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import MessageKit
import MessageInputBar

class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    
    func currentSender() -> Sender {
        // TODO: firebase の uid にする
        return Sender(id: "my_unique_id", displayName: "やまたつ")
    }
    
    func oshidoriSender() -> Sender {
        return Sender(id: "Oshidori", displayName: "おしどり")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    // 会話の中身を記録する用　MessageKitで使うために必要
    var messageList: [Message] = []
    
    // おしどりが話す内容
    enum oshidoriContent: String {
        case firstContent = "おしどりに預けたいメッセージを書いてね！"
        case afterWroteMessage = "このメッセージを預けますか？ 行いたいアクションのメッセージをタップするか、入力してください！"
        case LastMessage = "お預かりします！お手紙を書いてくれてありがとうございます！画面が遷移するよ！"
    }
    
    // chatのstatusフラグ
    var chatStatusFlag :chatStatus?
    
    // chatのstatus
    enum chatStatus{
        case selectContentType
        case afterWroteMessage
        case selectSendType
    }
    
    func isAfterWroteMessage() -> Bool{
        if chatStatusFlag == chatStatus.afterWroteMessage {
            return true
        }
        return false
    }
    
    // ボタン
    enum selectButtonContent: String {
        case edit = "編集"
        case keep = "預ける"
    }
    
    // 日付をフォーマットするために必要
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
      
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            // messageListにメッセージの配列をいれて
            self.messageList.append(self.getOshidoriMessages())
            // messagesCollectionViewをリロードして
            self.messagesCollectionView.reloadData()
            // 一番下までスクロールする
            self.messagesCollectionView.scrollToBottom()
        }
        
        // 初期化
        chatStatusFlag = chatStatus.selectContentType
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    // おしどりから放たれる言葉
    func getOshidoriMessages() -> Message {
        var str = ""
        if chatStatusFlag == chatStatus.selectContentType {
            str = oshidoriContent.firstContent.rawValue
        }
        if chatStatusFlag == chatStatus.afterWroteMessage {
            str = oshidoriContent.afterWroteMessage.rawValue
        }
        if chatStatusFlag == chatStatus.selectSendType {
            str = oshidoriContent.LastMessage.rawValue
        }
        let message = Message(text: str, sender: oshidoriSender(), messageId: UUID().uuidString, date: Date())
        return message
    }
    
    // メッセージを作成して、表示している.
    // 初期表示以外はここを通さなければ表示されない。
    private func insertNewMessage(_ message: Message) {
        messageList.append(message)
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

    
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    private func getColletionRef() -> CollectionReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("users").document(uid).collection("messages")
    }
    func save(_ message: Message) {
        print("Firestoreへセーブ")
        let collectionRef = getColletionRef()
        collectionRef.addDocument(data: message.representation)
    }
    
   
}

extension ChatViewController: MessageInputBarDelegate {
    
    // メッセージを入力するMessageInputBarの送信ボタンを押したときに発生するファンクション
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let str = component as? String {
                let message = Message(text: str, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                
                insertNewMessage(message)
                chatStatusFlag = chatStatus.afterWroteMessage
                
                
                if chatStatusFlag == chatStatus.afterWroteMessage {
                    insertNewMessage(getOshidoriMessages())
                    let editMessage = Message(text: selectButtonContent.edit.rawValue, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                    let keepMessage = Message(text: selectButtonContent.keep.rawValue, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                    insertNewMessage(editMessage)
                    insertNewMessage(keepMessage)
                }
                //save(message)
            }
        }
        // 送信したら、空っぽにする
        inputBar.inputTextView.text = String()
        // 一番下にスクロールする。アニメーション付き
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}

// メッセージのdelegate
extension ChatViewController{
    
    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        // TODO:ボタンの時は色を変えたい。
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    // メッセージの背景色を変更している（デフォルトは自分：緑、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: message) ?
            UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    // メッセージを吹き出し風にする。尻尾みたいなの。
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // message.senderで送信者を判断できる！
        if message.sender == oshidoriSender() {
            let avatar = Avatar(image: UIImage(named: "Oshidori_icon"), initials: "O")
            avatarView.set(avatar: avatar)
        } else {
            // TODO: 名前からinitial作っても面白いかも
            let avatar = Avatar(image: UIImage(named: ""), initials: "Y")
            avatarView.set(avatar: avatar)
        }
    }
    
    // メッセージの上に文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                             NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
        }
        return nil
    }
    
    // メッセージの上に文字を表示（名前）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        if isAfterWroteMessage() {
            return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    
    // 各ラベルの高さを設定（デフォルト0なので必須）
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 10 }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}


