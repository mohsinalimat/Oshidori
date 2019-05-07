//
//  MessageRoomViewController.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/7.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView

class MessageRoomViewController: MessagesViewController {

    // 会話の中身を記録する用　MessageKitで使うために必要
    var messageList: [Message] = []
    
    // userInfo を入れておく場所
    var userInformation : UserInformation?
    
    var messageId :String?
    
    // firebase 関連
    private let db = Firestore.firestore()
    
    // 日付をフォーマットするために必要
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        customizeMessageKit()
        // プロパティのUserInfoに入れる。
        getUserInfo()
        
        getMessages()
        
        DispatchQueue.main.async {
            // messageListにメッセージの配列をいれて
            //self.messageList.append(self.getOshidoriMessages())
            // messagesCollectionViewをリロードして
            self.messagesCollectionView.reloadData()
            // 一番下までスクロールする
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    // サンプル用に適当なメッセージ
    func getMessages() -> [Message] {
        return [
            createMessage(text: "あ"),
            createMessage(text: "い"),
            createMessage(text: "う"),
            createMessage(text: "え"),
            createMessage(text: "お"),
            createMessage(text: "か"),
            createMessage(text: "き"),
            createMessage(text: "く"),
            createMessage(text: "け"),
            createMessage(text: "こ"),
            createMessage(text: "さ"),
            createMessage(text: "し"),
            createMessage(text: "すせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"),
        ]
    }
    
    func createMessage(text: String) -> Message {
        _ = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                           .foregroundColor: UIColor.black])
        return Message(text: text, sender: currentSender(), messageId: "T##String", date: Date())
    }
}

extension MessageRoomViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        createAndInsertMessageFromeUser(text)
    }
}

extension MessageRoomViewController: MessagesLayoutDelegate {
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
    
    // create and insertNewMessage
    func createAndInsertMessageFromeUser(_ text: String) {
        let message = Message(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
        insertNewMessage(message)
    }
    
    func createAndInsertMessageFromOshidori(_ text: String) {
        let message = Message(text: text, sender: oshidoriSender(), messageId: UUID().uuidString, date: Date())
        insertNewMessage(message)
    }
    
    // メッセージを見えるようにしている
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
}

extension MessageRoomViewController: MessageCellDelegate {
    // メッセージのセルがタップされた時を検知するため。反応なし。
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
    }
}


extension MessageRoomViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
//        guard let name = userInformation?.name else {
//            return Sender(senderId: "", displayName: "")
//        }
//        return Sender(senderId: getUid(), displayName: name)
        return Sender(senderId: "", displayName: "")
    }
    
    func oshidoriSender() -> SenderType {
        return Sender(senderId: "Oshidori", displayName: "おしどり")
    }
    
    func partnerSender() -> SenderType {
        guard let partnerName = userInformation?.partnerName, let partnerId = userInformation?.partnerId else {
            return Sender(senderId: "", displayName: "")
        }
        return Sender(senderId: partnerId, displayName: partnerName)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
}

// firebase関連
extension MessageRoomViewController {
    private func getRoomMessagesCollectionRef() -> CollectionReference? {
        guard let roomId = userInformation?.roomId, let messageId = messageId else {
            return nil
        }
        return db.collection("rooms").document(roomId).collection("messages").document(messageId).collection("messages")
    }
    
    private func getTimelineColletionRef() -> CollectionReference {
        return db.collection("timelineMessages")
    }
    
    private func getUserInformationRef() -> DocumentReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("users").document(uid).collection("info").document(uid)
    }
    
    private func getUid() -> String {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
            return ""
        }
        return uid
    }

    func getUserInfo() {
        // userInformaitonの初期化。情報を持ってくる
        getUserInformationRef().getDocument{ (document, error) in
            if let userInformation = document.flatMap({
                $0.data().flatMap({ (data) in
                    return UserInformation(data: data)
                })
            }) {
                // 上記で得た内容を保存する
                self.userInformation = userInformation
            } else {
                // TODO: エラーへの対処
            }
        }
    }
}

extension MessageRoomViewController {
    func customizeMessageKit() {
        // カスタマイズ
        messageInputBar.inputTextView.placeholder = "メッセージを入力してね！"
        messageInputBar.sendButton.image = UIImage(named: "Send_icon")
        messageInputBar.sendButton.title = nil
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            // ここで自分のアイコンをzeroにしている！
            layout.setMessageOutgoingAvatarSize(.zero)
        }
    }
}

extension MessageRoomViewController: MessagesDisplayDelegate {
    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
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
        if message.sender.senderId == oshidoriSender().senderId {
            let avatar = Avatar(image: UIImage(named: "Oshidori_icon"), initials: "O")
            avatarView.set(avatar: avatar)
        }
    }
    
    // メッセージの上に文字を表示
    //    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    //        if indexPath.section % 3 == 0 {
    //            return NSAttributedString(
    //                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
    //                attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
    //                             NSAttributedString.Key.foregroundColor: UIColor.darkGray]
    //            )
    //        }
    //        return nil
    //    }
    
    // メッセージの上に文字を表示（名前）
    //    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    //        let name = message.sender.displayName
    //        if isAfterWroteMessage() {
    //            return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    //        }
    //        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    //    }
    
    // メッセージの下に文字を表示（日付）
    //    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    //        let dateString = formatter.string(from: message.sentDate)
    //        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    //    }
    
    // 各ラベルの高さを設定（デフォルト0なので必須）
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 6 }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 13
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
}



