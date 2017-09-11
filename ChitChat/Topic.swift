//
//  Topic.swift
//  ChitChat
//
//  Created by Tomer Buzaglo on 10/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Topic{
    let id: String
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    convenience init?(snapshot: DataSnapshot){
        guard
            let json = snapshot.value as? Dictionary<String, Any>,
            let name = json["name"] as? String,
            let id = json["id"] as? String
            else{return nil}
        self.init(id:id, name:name)
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name
        ]
    }
    var description:String{
        return "id: \(id)\nName: \(name)"
    }
}
