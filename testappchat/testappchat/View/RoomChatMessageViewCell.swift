//
//  RommChatMessageViewCell.swift
//  testappchat
//
//  Created by Nguyen Van Phong on 03/12/2017.
//  Copyright © 2017 phong.vn.com. All rights reserved.
//

import UIKit
import AVFoundation

class RoomChatMessageViewCell: UICollectionViewCell {
    
    var message: Messages?
    var roomChatController: RoomChatController?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "playbutton")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    let textChat: UITextView = {
        let text = UITextView()
        text.font = UIFont.systemFont(ofSize: 16)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = UIColor.clear
        text.isEditable = false
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
    
    
    lazy var messageImage: UIImageView = {
        let imageMess = UIImageView()
        imageMess.translatesAutoresizingMaskIntoConstraints = false
        imageMess.layer.cornerRadius = 16
        imageMess.layer.masksToBounds = true
        imageMess.contentMode = .scaleAspectFill
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleZoom))
        imageMess.addGestureRecognizer(tapGesture)
        imageMess.isUserInteractionEnabled = true
        return imageMess
    }()
  
    @objc func handleZoom(tapGesture: UITapGestureRecognizer){
        
        if message?.videoUrl != nil{
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView{
            self.roomChatController?.performZoomInfoStartingImageView(startingImageView: imageView)
        }
    }
    
    var playerlayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc func handlePlay(){
        if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString){
            player = AVPlayer(url: url)
            playerlayer = AVPlayerLayer(player: player)
            playerlayer?.frame = bubblesView.bounds
            bubblesView.layer.addSublayer(playerlayer!)
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerlayer?.removeFromSuperlayer()
        player?.pause()
    }
    
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
        
        //play button
        bubblesView.addSubview(playButton)
        
        playButton.centerXAnchor.constraint(equalTo: bubblesView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubblesView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        //loading
        bubblesView.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubblesView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubblesView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
