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
    
    // 会話の中身を記録する用　MessageKitで使うために必要
    var messageList: [Message] = []
    
    // 最終的に送る内容
    var sendTempMessage: Message?
    
    // おしどりが話す内容
    enum oshidoriContent: String {
        case firstContent = "おしどりに預けたいメッセージを書いてね！"
        case afterWroteMessage = "このメッセージを預けますか？ 預ける場合は「預ける」か「1」を、編集する場合は「編集」か「2」を入力してください！"
        case lastMessage = "お預かりします！お手紙を書いてくれてありがとうございます！"
        case continueMessage = "もう一度メッセージを書きますか？書く場合は、「書く」または「1」を入力してください！"
    }
    
    // chatのstatusフラグ
    var chatStatusFlag :chatStatus?
    
    // chatのstatus
    enum chatStatus{
        case selectContentType
        case afterWroteMessage
        case selectSendType
        case enterError
    }
    
    // 状態の判断
    func isSelectContentType() -> Bool{
        if chatStatusFlag == chatStatus.selectContentType {
            return true
        }
        return false
    }
    func isAfterWroteMessage() -> Bool{
        if chatStatusFlag == chatStatus.afterWroteMessage {
            return true
        }
        return false
    }
    func isSelectSendType() -> Bool{
        if chatStatusFlag == chatStatus.selectSendType {
            return true
        }
        return false
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
        
        // 初期ステータスを入れる
        chatStatusFlag = chatStatus.selectContentType
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    // おしどりから放たれる言葉を状態によって変更する
    func getOshidoriMessages() -> Message {
        var str = ""
        // Q.オプショナルバインディングは必要ではない？
        switch chatStatusFlag! {
        case chatStatus.selectContentType:
            str = oshidoriContent.firstContent.rawValue
        case chatStatus.afterWroteMessage:
            str = oshidoriContent.afterWroteMessage.rawValue
        case chatStatus.selectSendType:
            str = oshidoriContent.lastMessage.rawValue
        default:
            str = "正しい値を入力してください！"
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
    
    // メッセージを見えるようにしている
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
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
    
    // TODO: タップの検知
    // タップを検知するため。反応なし。
    //    func didTapMessage(in cell: MessageCollectionViewCell) {
    //        if !isAfterWroteMessage() {
    //            return
    //        }
    //        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
    //        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
    //        let tapMessage = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
    //        print(tapMessage)
    //        print("🌞🌞🌞🌞🌞🌞🌞🌞🌞")
    //        let pre = tapMessage.kind
    //    }
    
    
    // firebase 関連
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
        var editFlag = false
        for component in inputBar.inputTextView.components {
            if let str = component as? String {
                let message = Message(text: str, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                
                switch  chatStatusFlag! {
                case chatStatus.selectContentType:
                    // ユーザが送ったメッセージを保存
                    sendTempMessage = message
                    // メッセージを送信して状態を変化
                    insertNewMessage(message)
                    chatStatusFlag = chatStatus.afterWroteMessage
                    insertNewMessage(getOshidoriMessages())
                    
                case chatStatus.afterWroteMessage:
                    insertNewMessage(message)
                    guard let sendMessage = sendTempMessage else {
                        // TODO:エラー処理
                        return
                    }
                    // 預ける場合
                    if message.content == "預ける" || message.content == "1"{
                        save(sendMessage)
                        sendTempMessage = nil
                        chatStatusFlag = chatStatus.selectSendType
                        insertNewMessage(getOshidoriMessages())
                    // 編集する場合
                    } else if message.content == "編集" || message.content == "2" {
                        editFlag = true
                        chatStatusFlag = chatStatus.selectContentType
                        insertNewMessage(getOshidoriMessages())
                    // 入力が無効だったとき
                    } else {
                        chatStatusFlag = chatStatus.enterError
                        insertNewMessage(getOshidoriMessages())
                        chatStatusFlag = chatStatus.afterWroteMessage
                        insertNewMessage(getOshidoriMessages())
                    }

                case chatStatus.selectSendType:
                    insertNewMessage(getOshidoriMessages())
                    
                default :
                    chatStatusFlag = chatStatus.enterError
                    insertNewMessage(getOshidoriMessages())
                    chatStatusFlag = chatStatus.selectContentType
                    insertNewMessage(getOshidoriMessages())

                }
            }
        }
        if editFlag == true {
            inputBar.inputTextView.text = sendTempMessage?.content
        } else {
            // 送信したら、空っぽにする
            inputBar.inputTextView.text = String()
        }
        
        // 一番下にスクロールする。アニメーション付き
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}

// メッセージのdelegate
extension ChatViewController{
    
//    func didTapMessage(in cell: MessageCollectionViewCell) {
//        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
//        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
//        let _ = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
//
//        switch message.kind {
//        case .text(let textMessage):
//            _ = textMessage
//        default:
//            break
//        }
//    }
    
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


