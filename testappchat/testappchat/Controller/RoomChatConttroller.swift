//
//  ChatLogConttroller.swift
//  testappchat
//
//  Created by Nguyen Van Phong on 01/12/2017.
//  Copyright © 2017 phong.vn.com. All rights reserved.
//

import UIKit
import Firebase

class RoomChatController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout{
    
    let cellId = "cellId"
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            obseverMessage()
        }
    }
    
    var messages = [Messages]()
    
    func obseverMessage(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.UserID else {
            return
        }
        
        let userMessageRef = Database.database().reference().child("user-message").child(uid).child(toId)
        
        userMessageRef.observe(.childAdded, with: { (Snap) in
            let messId = Snap.key
            let messageRef = Database.database().reference().child("messages").child(messId)
            messageRef.observeSingleEvent(of: .value, with: { (snapShot) in
                guard let dictionary = snapShot.value as? [String: AnyObject] else{
                    return
                }
                let message = Messages()
                message.setValuesForKeys(dictionary)
                
                if message.chatParterId() == self.user?.UserID {
                    self.messages.append(message)
                    DispatchQueue.main.async { self.collectionView?.reloadData() }
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message...."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        return textField
    }()
    
    let sendMessButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor(r:33, g:159, b:254), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return sendButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        //collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.register(RoomChatMessageViewCell.self, forCellWithReuseIdentifier: cellId)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
    }
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    lazy var inputContainerView: UIView = {
        let containerview = UIView()
        containerview.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        containerview.backgroundColor = UIColor.white
        
        containerview.addSubview(sendMessButton)
        
        sendMessButton.rightAnchor.constraint(equalTo: containerview.rightAnchor).isActive = true
        sendMessButton.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        sendMessButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendMessButton.heightAnchor.constraint(equalTo: containerview.heightAnchor).isActive = true
        
        containerview.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerview.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendMessButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo:  containerview.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r:220, g:220, b:220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerview.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerview.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerview.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerview.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return containerview
    }()
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! RoomChatMessageViewCell
        let message = messages[indexPath.row]
        cell.textChat.text = message.text
        
        //setup bubbles
        setupCell(cell: cell, message: message)
        
        cell.bubbleWidthAnchor?.constant = estimateFrameFortext(text: message.text!).width + 32
        return cell
    }
    
    private func setupCell(cell: RoomChatMessageViewCell, message: Messages){
        
        if let profileImage = self.user?.profileImageUrl{
            cell.profileImageviewSender.loadimageUsingWithCacheUrl(urlString: profileImage)
        }
        
        if message.fromID == Auth.auth().currentUser?.uid{
            // sender
            cell.bubblesView.backgroundColor = RoomChatMessageViewCell.blueColor
            cell.textChat.textColor = .white
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
            cell.profileImageviewSender.isHidden = true
        }else{
            //receiver
            cell.bubblesView.backgroundColor = UIColor(r:240, g:240, b:240)
            cell.textChat.textColor = .black
            cell.profileImageviewSender.isHidden = false
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        if let text = messages[indexPath.item].text{
            height = estimateFrameFortext(text: text).height + 20
        }
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameFortext(text: String)-> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    @objc func handleBack(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard let text = inputTextField.text, !text.isEmpty else {
            self.sendMessButton.isEnabled = false
            return
        }
        // enable okButton if all conditions are met
        self.sendMessButton.isEnabled = true
    }
    
    @objc func handleSend(){
            let ref = Database.database().reference().child("messages")
            let toID = user?.UserID
            let fromID = Auth.auth().currentUser?.uid
            let timeStamp = Int(NSDate().timeIntervalSince1970)
            let childRef = ref.childByAutoId()
            let values = ["text": inputTextField.text!,"toID": toID,"fromID": fromID, "timestamp": timeStamp] as [String : Any]

            childRef.updateChildValues(values){ (error, ref) in
                if error != nil{
                    print(error)
                    return
                }
                
                let userMessRef = Database.database().reference().child("user-message").child(fromID!).child(toID!)
                let messId = childRef.key
                userMessRef.updateChildValues([messId: 1])
                
                let recipientUserMessageRef = Database.database().reference().child("user-message").child(toID!).child(fromID!)
                recipientUserMessageRef.updateChildValues([messId: 1])
            }
            inputTextField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        handleSend()
        return true
    }
}
