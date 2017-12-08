//
//  Messages.swift
//  testappchat
//
//  Created by Nguyen Van Phong on 01/12/2017.
//  Copyright © 2017 phong.vn.com. All rights reserved.
//

import UIKit
import Firebase

class Messages: NSObject {
    @objc var fromID: String?
    @objc var toID: String?
    @objc var text: String?
    @objc var timestamp: NSNumber?
    
    @objc var imageUrl: String?
    @objc var imageWidth: NSNumber?
    @objc var imageHeight: NSNumber?
    
    func chatParterId() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID: fromID
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        fromID = dictionary["fromID"] as? String
        text = dictionary["text"] as? String
        toID = dictionary["toID"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
    }
}
