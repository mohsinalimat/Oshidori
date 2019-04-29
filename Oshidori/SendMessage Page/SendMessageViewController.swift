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

class SendMessageViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    // 会話の中身を記録する用　MessageKitで使うために必要
    var messageList: [Message] = []
    
    // 最終的に送る内容
    var sendTempMessage: Message?
    
    // contentTypeを保存しておく場所
    var tmpStoreContentType: String?
    
    // userInfo を入れておく場所
    var userInformation : UserInformation?
    
    // contentTypeに使用する言葉
    let THANKYOU = "ありがとう"
    let SORRY = "ごめんね"
    let LISTEN = "あのね"
    
    // selectSendTypeに使用する言葉
    let KEEP = "預ける"
    let EDIT = "編集"
    let REWRITE = "書き直す"
    
    // おしどりが話す内容
    enum oshidoriContent: String {
        case firstContent = "お手紙の種類をタップして選んでね！"
        case beforeWriteMessage = "おしどりに預けたいメッセージを書いてね！"
        case afterWroteMessage = "この手紙を預けますか？ メッセージをタップして選択してください！編集する場合は、「編集」のメッセージを送ってね！"
        case lastMessage = "お預かりします！お手紙を書いてくれてありがとうございます！"
        case continueMessage = "もう一度メッセージを書きますか？書く場合は、「書く」または「1」を入力してください！"
    }
    
    // chatのstatusフラグ
    var chatStatusFlag :chatStatus?
    
    // chatのstatus
    enum chatStatus{
        case selectContentType
        case beforeWriteMessage
        case afterWroteMessage
        case selectSendType
        case enterError
    }
    
    // 日付をフォーマットするために必要
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    weak var delegate: ReceiveMessageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MessageKitで作られる画面の構成をカスタマイズする
        customizeMessageKit()
        // delegateを入れる
        insertDelegate()
        // 初期ステータスを入れる
        chatStatusFlag = chatStatus.selectContentType
        // userInformaitonの初期化。情報を持ってくる
        getUserInformationRef().getDocument{ (document, error) in
            if let userInformation = document.flatMap({
                $0.data().flatMap({ (data) in
                    return UserInformation(data: data)
                })
            }) {
                // 上記で得た内容を保存する
                self.userInformation = userInformation
                debugPrint("🌞City: \(userInformation.name)")
            } else {
                debugPrint("Document does not exist")
            }
        }
        
        DispatchQueue.main.async {
            // messageListにメッセージの配列をいれて
            self.messageList.append(self.getOshidoriMessages())
            // messagesCollectionViewをリロードして
            self.messagesCollectionView.reloadData()
            // 一番下までスクロールする
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        insertContentTypeToUserMessage()
    }
    
    // おしどりから放たれる言葉を状態によって変更する
    func getOshidoriMessages() -> Message {
        var str = ""
        // Q.オプショナルバインディングは必要ではない？
        switch chatStatusFlag! {
        case chatStatus.selectContentType:
            str = oshidoriContent.firstContent.rawValue
        case chatStatus.beforeWriteMessage:
            str = oshidoriContent.beforeWriteMessage.rawValue
        case chatStatus.afterWroteMessage:
            str = oshidoriContent.afterWroteMessage.rawValue
        case chatStatus.selectSendType:
            str = oshidoriContent.lastMessage.rawValue
        default:
            str = "正しい値を入力してください！"
        }
        
        return Message(text: str, sender: oshidoriSender(), messageId: UUID().uuidString, date: Date())
    }
    
    func currentSender() -> Sender {
        guard let name = userInformation?.name else {
            return Sender(id: getUid(), displayName: "")
        }
        return Sender(id: getUid(), displayName: name)
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
    
    // firebase 関連
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    private func getRoomMessagesCollectionRef() -> CollectionReference {
        guard let roomId = userInformation?.roomId else {
            fatalError("roomIdを取得できませんでした。")
        }
        return db.collection("rooms").document(roomId).collection("messages")
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

    func save(_ message: Message) {
        // falseだったら実行されるようだ。guardは条件に一致なかった場合に、処理を中断させるための構文
        guard isAfterWroteMessage() else {
            return
        }
        debugPrint("Firestoreへmessageをセーブ（roomとtimeline）")
        saveToRoomMessges(message)
        saveToTimelineMessages(message)
    }
    
    func saveToRoomMessges(_ message: Message) {
        let roomCollectionref = getRoomMessagesCollectionRef()
        roomCollectionref.addDocument(data: message.representation){ error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.delegate?.reloadDate()
        }
    }
    
    func saveToTimelineMessages(_ message: Message) {
        let timelineMessagesCollectionRef = getTimelineColletionRef()
        timelineMessagesCollectionRef.addDocument(data: message.representation) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
}

// メッセージを作成,表示
extension SendMessageViewController {
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

// 状態の判断
extension SendMessageViewController {
    
    func isSelectContentType() -> Bool{
        if chatStatusFlag == chatStatus.selectContentType {
            return true
        }
        return false
    }
    func isBeforeWriteMessage() -> Bool{
        if chatStatusFlag == chatStatus.beforeWriteMessage {
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
}

extension SendMessageViewController {
    
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

extension SendMessageViewController {
    func insertDelegate() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messageCellDelegate = self
    }
}

extension SendMessageViewController: MessageInputBarDelegate{
    
    // メッセージを入力するMessageInputBarの送信ボタンを押したときに発生するファンクション
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let str = component as? String {
                guard let contentType = tmpStoreContentType else {
                    return
                }
                let message = Message(text: str, sender: currentSender(), messageId: UUID().uuidString, date: Date(),contentType: contentType)
                
                switch  chatStatusFlag! {
                    
                case chatStatus.selectContentType:
                    reactionWhenSelectContentType(textMessage: str)
                case chatStatus.beforeWriteMessage:
                    // ユーザが送ったメッセージを保存
                    sendTempMessage = message
                    // メッセージを送信して状態を変化
                    insertNewMessage(message)
                    chatStatusFlag = chatStatus.afterWroteMessage
                    insertNewMessage(getOshidoriMessages())
                    
                    // 「編集」「預ける」をボタンの代わりに送る
                    // TODO: 画像で、ボタンのようにしたい。その時は、画像の名前になるのか？比較要素が。
                    createAndInsertMessageFromeUser(REWRITE)
                    createAndInsertMessageFromeUser(KEEP)
                    
                    cleanTextBoxAndScroll(inputBar: inputBar)
                case chatStatus.afterWroteMessage:
                    reactionWhenSelectSendType(textMessage: str)
                    
                case chatStatus.selectSendType:
                    insertNewMessage(getOshidoriMessages())
                    messagesCollectionView.scrollToBottom(animated: true)
                default :
                    chatStatusFlag = chatStatus.enterError
                    insertNewMessage(getOshidoriMessages())
                    chatStatusFlag = chatStatus.selectContentType
                    insertNewMessage(getOshidoriMessages())
                }
            }
        }
    }
    
    func cleanTextBoxAndScroll(inputBar: MessageInputBar) {
        // 空っぽにする
        inputBar.inputTextView.text = String()
        // 一番下にスクロールする。アニメーション付き
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    func reactionWhenSelectContentType(textMessage: String) {
        // selectContentTypeの時
        if textMessage == THANKYOU {
            storeContentType_changeStatus(storeText: textMessage)
        } else if textMessage == SORRY {
            storeContentType_changeStatus(storeText: textMessage)
        } else if textMessage == LISTEN {
            storeContentType_changeStatus(storeText: textMessage)
        }
    }
    
    func reactionWhenSelectSendType(textMessage: String) {
        if textMessage == EDIT {
            selectEditAction()
        } else if textMessage == KEEP {
            if let sendMessage = sendTempMessage {
                selectKeepAction(sendMessage: sendMessage)
            }
        } else if textMessage == REWRITE {
            selectResetAction()
        } else {
            //タップしても反応しないようにする
        }
    }
    
    func storeContentType_changeStatus(storeText: String) {
        createAndInsertMessageFromOshidori("「" + storeText + "」だね！")
        tmpStoreContentType = storeText
        chatStatusFlag = chatStatus.beforeWriteMessage
        insertNewMessage(getOshidoriMessages())
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    func insertContentTypeToUserMessage() {
        createAndInsertMessageFromeUser(THANKYOU)
        createAndInsertMessageFromeUser(SORRY)
        createAndInsertMessageFromeUser(LISTEN)
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    func selectKeepAction(sendMessage: Message) {
        save(sendMessage)
        sendTempMessage = nil
        chatStatusFlag = chatStatus.selectSendType
        insertNewMessage(getOshidoriMessages())
        // inputBarFillWhenEditAction()
        messagesCollectionView.scrollToBottom(animated: true)
        chatStatusFlag = chatStatus.selectContentType
    }
    
    func selectEditAction() {
        chatStatusFlag = chatStatus.beforeWriteMessage
        insertNewMessage(getOshidoriMessages())
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    func selectResetAction() {
        tmpStoreContentType = nil
        sendTempMessage = nil
        chatStatusFlag = chatStatus.selectContentType
        insertNewMessage(getOshidoriMessages())
        insertContentTypeToUserMessage()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}

extension SendMessageViewController: MessageCellDelegate {
    // メッセージのセルがタップされた時を検知するため。反応なし。
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard !isBeforeWriteMessage() else {
            return
        }
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let tapMessage = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch tapMessage.kind {
        case .text(let textMessage):
            // selectContentTypeの時
            reactionWhenSelectContentType(textMessage: textMessage)
            // wroteMessageの時
            reactionWhenSelectSendType(textMessage: textMessage)
        default:
            break
        }
    }
}

// メッセージのdelegate
extension SendMessageViewController{
    
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


