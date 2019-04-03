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
        return Sender(id: "any_unique_id", displayName: "Steven")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    var messageList: [Message] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    // Creating Messages
    private func insertNewMessage(_ message: Message) {
//        guard !messageList.contains(message) else {
//            return
//        }
//
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
        
//        messagesCollectionView.reloadData()
//
//        if shouldScrollToBottom {
//            DispatchQueue.main.async {
//                self.messagesCollectionView.scrollToBottom(animated: true)
//            }
//        }
        
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

    //    @IBOutlet weak var testField: UITextField!
    //    @IBOutlet weak var testLabel: UILabel!
    //    @IBOutlet weak var testButton: UIButton!
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    
    //private var messages: [Message] = []
    
    private func getColletionRef() -> CollectionReference {
        guard let uid = User.shared.getUid() else {
            fatalError("Uidを取得できませんでした。")
        }
        return db.collection("users").document(uid).collection("messages")
    }
    
    func save(_ message: Message) {
        print("Firestoreへセーブ")
        let collectionRef = getColletionRef()
        
//        if let id = message.id { // データがある場合
//            let documentRef = collectionRef.document(id)
//            // データの上書きを行なっている
//            documentRef.setData(message.toDictionary())
//        } else { // データがない場合
//            // データを追加している
//            let documentRef = collectionRef.addDocument(data: message.toDictionary())
//            message.id = documentRef.documentID
//        }
    }
    
    @IBAction func didTapTestButton(_ sender: Any) {
//        guard let content = testField.text else {
//            alert("エラー", "入力してください", nil)
//            return
//        }
//        let message = Message()
//        message.content = content
//        save(message)
    }
    
}

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components {
            if let str = component as? String {
                let message = Message(text: str, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                insertNewMessage(message)
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}


//extension ChatViewController: MessageInputBarDelegate {
//
//    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
//        // 1
//        let message = Message(user: user, content: text)
//        // 2
//        save(message)
//        print("🌞🌞🌞🌞🌞")
//        // 3
//        inputBar.inputTextView.text = ""
//    }
//
//
//}
