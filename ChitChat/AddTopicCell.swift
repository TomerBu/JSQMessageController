//
//  AddTopicCell.swift
//  ChitChat
//
//  Created by Tomer Buzaglo on 07/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//

import UIKit
import FirebaseDatabase


class AddTopicCell: UITableViewCell {
    @IBOutlet weak var topicText: UITextField!

    @IBAction func addTopic(_ sender: UIButton) {
        let topicName = topicText.text ?? ""
        
        let ref = Database.database().reference(withPath: "Topics").childByAutoId()
        let topic = Topic(id: ref.key, name: topicName)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat], animations: { 
            sender.transform = CGAffineTransform(rotationAngle: .pi)
        }) { (completed) in }
        
        
        ref.setValue(topic.toDictionary()) { (error, ref) in
            if error == nil {
                self.topicText.text = nil
            }
            sender.layer.removeAllAnimations()
            sender.transform = CGAffineTransform.identity
        }
    }
}
