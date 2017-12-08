//
//  ViewController.swift
//  testappchat
//
//  Created by Nguyen Van Phong on 21/11/2017.
//  Copyright © 2017 phong.vn.com. All rights reserved.
//

import UIKit
import Firebase

class HistoryChatController: UITableViewController {

    var historyChatController: HistoryChatController?
    var messages = [Messages]()
    var messageDictionary = [String: Messages]()
    let cellId = "cellId"
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let image = UIImage(named:"newmessage")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:  image, style: .plain, target:  self, action:  #selector(handleNewMessage))
    
        tableView.register(userCell.self, forCellReuseIdentifier: cellId)
        
        checkIfUserIsLoggedIn()
        
    }
    
    func observeUserMessage(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let ref = Database.database().reference().child("user-message").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            Database.database().reference().child("user-message").child(uid).child(userId).observe(.childAdded, with:{ (snap) in
                
                let messageID = snap.key
                self.fetchMessageWithMessageId(messageId: messageID)

            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    private func fetchMessageWithMessageId(messageId: String){
        let messageReference = Database.database().reference().child("messages").child(messageId)
        
        messageReference.observeSingleEvent(of: .value, with: { (snapshots) in
            
            if let value = snapshots.value as? [String: AnyObject] {
                let message = Messages(dictionary: value)
                
                if let chatPartnerId = message.chatParterId(){
                    self.messageDictionary[chatPartnerId] = message
                }
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleReloadDataTable), userInfo: nil, repeats: false)
            }
        }, withCancel: nil)
        
    }
    
    private func fetchMessageWithMessageId(messageId: String){
        let messageReference = Database.database().reference().child("messages").child(messageId)
        
        messageReference.observeSingleEvent(of: .value, with: { (snapshots) in
            
            if let value = snapshots.value as? [String: AnyObject] {
                let message = Messages()
                
                message.setValuesForKeys(value)
                
                if let chatPartnerId = message.chatParterId(){
                    self.messageDictionary[chatPartnerId] = message
                }
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleReloadDataTable), userInfo: nil, repeats: false)
            }
        }, withCancel: nil)
        
    }

    @objc func handleReloadDataTable(){
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort(by: {(message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! userCell
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatParterId = message.chatParterId() else{
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatParterId)
        
        ref.observeSingleEvent(of: .value, with: { (Snapshot) in
            
            print(Snapshot)
            guard let dictionary = Snapshot.value as? [String: AnyObject] else{
                return
            }
            
            let user = User()
            user.UserID = chatParterId
            user.setValuesForKeys(dictionary)
            self.showChatController(user: user)
            
        }, withCancel: nil)
    }
    
    func checkIfUserIsLoggedIn(){
        //check user is not logged
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User){
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        observeUserMessage()
        let title = UIButton(type: .custom)
        title.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerview = UIButton()
        containerview.translatesAutoresizingMaskIntoConstraints = false
        title.addSubview(containerview)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadimageUsingWithCacheUrl(urlString: profileImageUrl)
        }
        
        containerview.addSubview(profileImageView)
        
        profileImageView.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: containerview.leftAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let userName = UILabel()
        containerview.addSubview(userName)
        userName.text = user.name
        userName.translatesAutoresizingMaskIntoConstraints = false
        userName.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        userName.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        userName.rightAnchor.constraint(equalTo: containerview.rightAnchor).isActive = true
        userName.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerview.centerXAnchor.constraint(equalTo: title.centerXAnchor).isActive = true
        containerview.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        containerview.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.navigationItem.titleView = title
        
    }
    
    @objc func showChatController(user: User){
        let chatController = RoomChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        let navController = UINavigationController(rootViewController: chatController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.historyChatController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func handleLogout(){
        do{
            try Auth.auth().signOut()
        }catch let loggoutError{
            print(loggoutError)
        }
        
        let loginController = LoginController()
        loginController.historychatController = self
        present(loginController, animated: true, completion: nil)
    }
}


