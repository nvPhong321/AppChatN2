//
//  UserCell.swift
//  testappchat
//
//  Created by Nguyen Van Phong on 01/12/2017.
//  Copyright © 2017 phong.vn.com. All rights reserved.
//

import UIKit
import Firebase

class userCell: UITableViewCell{
    
    var message: Messages? {
        didSet{
            
            setupNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue{
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
            
        }
    }
    
    private func setupNameAndProfileImage(){
        
        let chatPartnerId: String?
        
        if message?.fromID == Auth.auth().currentUser?.uid {
            chatPartnerId = message?.toID
        }else{
            chatPartnerId = message?.fromID
        }
        
        if let id = message?.chatParterId(){
            let ref = Database.database().reference().child("users").child(id)
            ref.observe(.value, with: {(snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadimageUsingWithCacheUrl(urlString: profileUrl)
                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"Imagedefault")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let time = UILabel()
        time.font = UIFont.systemFont(ofSize: 13)
        time.textColor = UIColor.darkGray
        time.translatesAutoresizingMaskIntoConstraints = false
        return time
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:  .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //profileImageView
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor , constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        //timeLabel
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)has not been implement")
    }
}
