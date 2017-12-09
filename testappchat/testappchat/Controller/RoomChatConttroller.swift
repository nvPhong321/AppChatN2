//
//  ChatLogConttroller.swift
//  testappchat
//
//  Created by Nguyen Van Phong on 01/12/2017.
//  Copyright © 2017 phong.vn.com. All rights reserved.
//

import UIKit
import Firebase

class RoomChatController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
                let message = Messages(dictionary: dictionary)
                
                if message.chatParterId() == self.user?.UserID {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        let indexpath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexpath , at: .bottom, animated: true)
                    }
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
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.setTitleColor(UIColor(r:33, g:159, b:254), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return sendButton
    }()
    
    lazy var uploadImage: UIImageView = {
        let imgUpload = UIImageView()
        imgUpload.image = UIImage(named: "sendimage")
        imgUpload.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleUploadTap))
        imgUpload.addGestureRecognizer(tapGesture)
        imgUpload.isUserInteractionEnabled = true
        return imgUpload
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
        setupkeyBoard()
    }
    
    func setupkeyBoard(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardShow), name: NSNotification.Name.UIKeyboardDidShow , object: nil)
    }
    
    @objc func handleKeyBoardShow(){
        if messages.count > 0 {
            let indexpath = IndexPath(item: self.messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexpath, at: .top, animated: true)
        }
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
        
        containerview.addSubview(self.uploadImage)
        
        self.uploadImage.leftAnchor.constraint(equalTo: containerview.leftAnchor, constant: 8).isActive = true
        self.uploadImage.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        self.uploadImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.uploadImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        containerview.addSubview(self.sendMessButton)
        
        self.sendMessButton.rightAnchor.constraint(equalTo: containerview.rightAnchor).isActive = true
        self.sendMessButton.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        self.sendMessButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.sendMessButton.heightAnchor.constraint(equalTo: containerview.heightAnchor).isActive = true
        
        containerview.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: self.uploadImage.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: self.sendMessButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo:  containerview.heightAnchor).isActive = true
        
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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! RoomChatMessageViewCell
        
        cell.roomChatController = self
        
        let message = messages[indexPath.row]
        cell.textChat.text = message.text
        
        //setup bubbles
        setupCell(cell: cell, message: message)
        
        if let text = message.text{
            cell.bubbleWidthAnchor?.constant = estimateFrameFortext(text: text).width + 32
            cell.textChat.isHidden = false
        }else if message.imageUrl != nil{
            cell.bubbleWidthAnchor?.constant = 200
            cell.textChat.isHidden = true
        }
        return cell
    }
    
    private func setupCell(cell: RoomChatMessageViewCell, message: Messages){
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImage.loadimageUsingWithCacheUrl(urlString: messageImageUrl)
            cell.messageImage.isHidden = false
            cell.bubblesView.backgroundColor = UIColor.clear
        }else{
            cell.bubblesView.backgroundColor = UIColor.clear
            cell.messageImage.isHidden = true        }
        
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
        let message = messages[indexPath.item]
        if let text = message.text{
            height = estimateFrameFortext(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue{
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameFortext(text: String)-> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    @objc func handleUploadTap(){
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage){
        let nameImage = NSUUID().uuidString
        let userId = Auth.auth().currentUser?.uid
        let storageRef = Storage.storage().reference().child("message_images").child(userId!).child("\(nameImage).jpg")
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.1){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata,error) in
                if error != nil{
                    print(error)
                    return
                }
                
                if let imageViewUrl = metadata?.downloadURL()?.absoluteString{
                    self.sendMessageWithUrl(imageUrl: imageViewUrl, image: image)
                }
                
            })
        }
    }
    
    private func sendMessageWithUrl(imageUrl: String, image: UIImage){
        let properties: [String: AnyObject] = ["imageUrl": imageUrl,"imageWidth": image.size.width,"imageHeight": image.size.height] as [String : AnyObject]
        sendmessageWithProperties(properties: properties)
        
    }
    
    private func sendmessageWithProperties(properties: [String: AnyObject]){
        let ref = Database.database().reference().child("messages")
        let toID = user?.UserID
        let fromID = Auth.auth().currentUser?.uid
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let childRef = ref.childByAutoId()
        var values: [String: AnyObject] = ["toID": toID,"fromID": fromID, "timestamp": timeStamp] as [String : AnyObject]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values){ (error, ref) in
            if error != nil{
                print(error)
                return
            }
            self.inputTextField.text = nil
            let userMessRef = Database.database().reference().child("user-message").child(fromID!).child(toID!)
            let messId = childRef.key
            userMessRef.updateChildValues([messId: 1])
            
            let recipientUserMessageRef = Database.database().reference().child("user-message").child(toID!).child(fromID!)
            recipientUserMessageRef.updateChildValues([messId: 1])
        }
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
        let properties = ["text": inputTextField.text!]
        sendmessageWithProperties(properties: properties as [String : AnyObject])
        inputTextField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    var backgroundView: UIView!
    var startingImageView: UIImageView!
    
    func performZoomInfoStartingImageView(startingImageView: UIImageView){
        
        // get size imageview
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        self.startingImageView = startingImageView
        self.startingImageView.isHidden = true
        
        let zoomImageView = UIImageView(frame: startingFrame!)
        zoomImageView.backgroundColor = UIColor.clear
        zoomImageView.image = startingImageView.image
        zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomImageView.isUserInteractionEnabled = true
        
        if let keywindow = UIApplication.shared.keyWindow{
            
            self.backgroundView = UIView(frame: keywindow.frame)
            self.backgroundView.backgroundColor = UIColor.black
            self.backgroundView.alpha = 0
            
            keywindow.addSubview(self.backgroundView)
            keywindow.addSubview(zoomImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:{
                
                self.backgroundView.alpha = 1
                self.inputContainerView.alpha = 0
                
                //h2 / w1 = h1/ w1
                //h2 = h1/ h1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keywindow.frame.width
                
                zoomImageView.frame = CGRect(x: 0, y: 0, width: keywindow.frame.width, height: self.startingFrame!.height)
                zoomImageView.center = keywindow.center
                
            } , completion: nil)
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOut = tapGesture.view{
            
            //animation zoom out
            zoomOut.layer.cornerRadius = 16
            zoomOut.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:{
                
                zoomOut.frame = self.startingFrame!
                self.backgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            } , completion:{ (completed: Bool) in
                
                //do something here later
                zoomOut.removeFromSuperview()
                self.startingImageView.isHidden = false
            })
        }
    }
}
