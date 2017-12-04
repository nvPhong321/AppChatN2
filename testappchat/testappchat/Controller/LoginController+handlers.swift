//
//  LoginController+handlers.swift
//  testappchat
//
//  Created by Nguyen Van Phong on 26/11/2017.
//  Copyright © 2017 phong.vn.com. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @objc func handleSelectProfileImageView(){
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else{
            print("Form is not valid")
            return
        }
        
        if email.isEmpty || password.isEmpty || name.isEmpty{
            self.createAlert(title: "Warning", message: "Please input name, email, password !!!")
            return
        }else{
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    //registration failure
                    print(error)
                    self.createAlert(title: "Error", message: "You can't sign up please check email!!!")
                    return
                }else{
                    //registration successful
                    guard let uid = user?.uid else{
                        return
                    }
                    
                    let nameImage = NSUUID().uuidString
                    let userId = Auth.auth().currentUser?.uid
                    let storageRef = Storage.storage().reference().child(userId!).child("\(nameImage).jpg")
                    
                    if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1){
                        
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata,error) in
                            if error != nil{
                                print(error)
                                return
                            }
                            
                            if let profileImageViewUrl = metadata?.downloadURL()?.absoluteString{
                                let values = ["name": name,"email": email,"profileImageUrl": profileImageViewUrl]
                                self.registerUserIntoDatabase(uid: uid, values:  values as [String : AnyObject])
                                self.createAlert(title: "", message: "Register success!!!")
                            }
                            
                        })
                    }
                }
            })
        }
    }
    
    func handleCheckUserNameRegister(){
        let databaseReff = Database.database().reference().child("users")
        
        databaseReff.queryOrdered(byChild: "name").queryEqual(toValue: self.nameTextField.text!).observe(.value, with: { snapshot in
            if snapshot.exists(){
                
                //User email exist
                self.createAlert(title: "Error", message: "You can't sign up please check name!!!")
            }
            else{
                //email does not [email id available]
                self.handleRegister()
            }
            
        })
    }
    
    func registerUserIntoDatabase(uid: String,values: [String: AnyObject]){
        let ref = Database.database().reference(fromURL: "https://messageios-31e08.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: {(error,ref)
            in
            
            if error != nil {
                print(error)
                return
            }else{
                let user = User()
                user.setValuesForKeys(values)
                self.historychatController?.setupNavBarWithUser(user: user)
                self.dismiss(animated: true, completion: nil)
                
            }
        })
    }
    
    func createAlert(title:String, message:String){
        
        var alert = UIAlertController(title: title, message: message,  preferredStyle: .alert)
        var action = UIAlertAction(title:"Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}





    
    
    
    


