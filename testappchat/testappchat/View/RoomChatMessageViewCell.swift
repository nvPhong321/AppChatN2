//
//  RommChatMessageViewCell.swift
//  testappchat
//
//  Created by Nguyen Van Phong on 03/12/2017.
//  Copyright © 2017 phong.vn.com. All rights reserved.
//

import UIKit

class RoomChatMessageViewCell: UICollectionViewCell {
    
    let textChat: UITextView = {
        let text = UITextView()
        text.font = UIFont.systemFont(ofSize: 16)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = UIColor.clear
        return text
    }()
    
    static let blueColor = UIColor(r:33, g:159, b:254)
    
    let bubblesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageviewSender: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 16
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let messageImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 16
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubblesView)
        addSubview(textChat)
        addSubview(profileImageviewSender)

        bubblesView.addSubview(messageImage)
        //messageImage
        messageImage.leftAnchor.constraint(equalTo: bubblesView.leftAnchor).isActive = true
        messageImage.rightAnchor.constraint(equalTo: bubblesView.rightAnchor).isActive = true
        messageImage.topAnchor.constraint(equalTo: bubblesView.topAnchor).isActive = true
        messageImage.widthAnchor.constraint(equalTo: bubblesView.widthAnchor).isActive = true
        messageImage.heightAnchor.constraint(equalTo: bubblesView.heightAnchor).isActive = true
        
        //bubbles view
        bubbleRightAnchor = bubblesView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        
        bubbleLeftAnchor = bubblesView.leftAnchor.constraint(equalTo: profileImageviewSender.rightAnchor, constant: 8)
        bubbleLeftAnchor?.isActive = false
        
        bubblesView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidthAnchor = bubblesView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubblesView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //text chat
        textChat.leftAnchor.constraint(equalTo: bubblesView.leftAnchor, constant: 8).isActive = true
        textChat.rightAnchor.constraint(equalTo: bubblesView.rightAnchor).isActive = true
        textChat.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textChat.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textChat.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //profile image sender
        profileImageviewSender.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageviewSender.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageviewSender.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageviewSender.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)has not been implement")
    }
}
