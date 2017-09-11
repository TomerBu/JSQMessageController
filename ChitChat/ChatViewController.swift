//
//  ChatViewController.swift
//  ChitChat
//
//  Created by Tomer Buzaglo on 10/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Photos

class ChatViewController: JSQMessagesViewController     {
    let storageRef = Storage.storage().reference(forURL: "gs://firechat-f1574.appspot.com")
    var messages = [JSQMessage]()
    var ref:DatabaseReference!
    var user:User!
    
    var topic:Topic!{
        didSet{
            self.title = topic.name
            ref =
                Database.database().reference(withPath: "TopicMessages").child(topic.id)
            user = Auth.auth().currentUser
        }
    }
    lazy var incoming: JSQMessagesBubbleImage  = {
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var outGoing: JSQMessagesBubbleImage  = {
        return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    
    // let outGoing = JSQMessagesBubbleImageFactory.init().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeMessages()
        //No Avatars:
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.senderId = user.uid
        self.senderDisplayName = user.displayName ?? "John Doe"
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!,
                               senderId: String!, senderDisplayName: String!, date: Date!) {
        
        guard let message = JSQMessage(senderId: senderId,
                                       senderDisplayName: senderDisplayName,
                                       date: date,
                                       text: text) else{return}
        ref.childByAutoId().setValue(message.toDictionary())
        finishSendingMessage()
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
    }
    
    func observeMessages(){
        let messageQuery = ref.queryLimited(toLast:25)
        
        messageQuery.observe(.childAdded, with: { snapshot -> Void in
            guard let m = JSQMessage(snapshot: snapshot) else {return}
            self.messages.append(m)
            self.finishReceivingMessage()
        })
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        //        let incoming  = JSQMessagesBubbleImageFactory.init().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        //
        //        let outGoing = JSQMessagesBubbleImageFactory.init().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        //
        let message = messages[indexPath.item]
        
        return message.senderId == self.senderId ? outGoing : incoming
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let name = messages[indexPath.item].senderDisplayName
        return NSAttributedString(string: name ?? "")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 17
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let msg = messages[indexPath.item]
        let str = msg.date?.shortDescription ?? Date().shortDescription
        return NSAttributedString(string: str)
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!,
                                 heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 17
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
}

extension ChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        
        // we now need the url of the image to upload.
        // we did an example were we got the image from the dictionary, but we don't want to hold the image in memory.
        //we want a URL to the image so we can upload it.
        guard let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL  else{return}
        
        //the url is not the file url, it's a url for requests...
        
        
        // grab the asset from the Photos framework:
        let asset = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil).firstObject
        
        //grab the fullSizeImageURL from the asset.
        asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, _) in
            guard let url = contentEditingInput?.fullSizeImageURL else{return}
            
            //CfpUByEWitQyDoUdjR1psYBdIR821505108476.92219IMG_0001.JPG
            //uidEpochDateImgName.Extenstion
            let path = "\(self.user.uid)\(Date().timeIntervalSince1970)\(url.lastPathComponent)"
            print(path)
            
            self.storageRef.child(path).putFile(from: url, metadata: nil, completion: { (metadata, error) in
                print(metadata?.path ?? "Error saving Image")
                
                if let error = error{
                    print(error)
                    return
                }
            })
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

extension Date{
    var shortDescription : String{
        get{
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.doesRelativeDateFormatting = true //today, yesterday :)
            
            return formatter.string(from: self)
        }
    }
}
/*
 aside:
 let formatter = DateFormatter()
 formatter.dateFormat = "dd-MM-yyyy"
 let date = formatter.date(from: "03-01-1990")
 messages.append(JSQMessage(senderId: "3", senderDisplayName: "Moshe", date: date, text: "Birthday?"))
 */
extension JSQMessage{
    func toDictionary() -> [String: Any]{
        return [
            "senderID" : senderId,
            "senderDisplayName" : senderDisplayName,
            "text" : text,
            "date" : date.timeIntervalSince1970
        ]
    }
    
    public convenience init?(snapshot: DataSnapshot) {
        guard let json = snapshot.value as? [String: Any] else {
            return nil
        }
        let senderID = json["senderID"] as! String
        let senderDisplayName = json["senderDisplayName"] as? String
        let text = json["text"] as? String
        let epoch = json["date"] as? TimeInterval ?? 0//Double
        
        let date = Date(timeIntervalSince1970: epoch)
        self.init(senderId: senderID,
                  senderDisplayName: senderDisplayName,
                  date: date,
                  text: text
        )
    }
    
    
}
