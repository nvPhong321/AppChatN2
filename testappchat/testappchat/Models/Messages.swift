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
    
    func chatParterId() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID: fromID
    }
}
