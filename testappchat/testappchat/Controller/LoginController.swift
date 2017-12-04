//
//  LoginController.swift
//  testappchat
//
//  Created by Nguyen Van Phong on 21/11/2017.
//  Copyright © 2017 phong.vn.com. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    var historychatController: HistoryChatController?
    var inputContainerViewHeightAnchor:NSLayoutConstraint?
    var nametextfieldHeightAnchor:NSLayoutConstraint?
    var emailtextfieldHeightAnchor:NSLayoutConstraint?
    var passwordtextfieldHeightAnchor:NSLayoutConstraint?
    var flag:Bool = true
    

    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r:80,g:101,b:161)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleLoginRegister(){
        if loginRegisterSegmentedcontrol.selectedSegmentIndex == 0 {
            handleLogin()
        }else{
            handleCheckUserNameRegister()
        }
    }
    
    let loginRegisterSegmentedcontrol: UISegmentedControl = {
        let sg = UISegmentedControl(items: ["Login", "Register"])
        sg.translatesAutoresizingMaskIntoConstraints = false
        sg.tintColor = UIColor.white
        sg.selectedSegmentIndex = 1
        sg.addTarget(self, action: #selector(handleLoginRegisterChanged), for: .valueChanged)
        return sg
    }()
    
    @objc func handleLoginRegisterChanged(){
        let title = loginRegisterSegmentedcontrol.titleForSegment(at: loginRegisterSegmentedcontrol.selectedSegmentIndex)
        registerButton.setTitle(title, for: .normal)
        
        //change height og inputContainerView
        inputContainerViewHeightAnchor?.constant = loginRegisterSegmentedcontrol.selectedSegmentIndex == 0 ? 100 :150
        
        //change height nametextfield
        nametextfieldHeightAnchor?.isActive = false
        nametextfieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo:  inputContainerView.heightAnchor, multiplier:  loginRegisterSegmentedcontrol.selectedSegmentIndex == 0 ? 0 : 1/3)
        nametextfieldHeightAnchor?.isActive = true
        
        //change height emailtextfield
        emailtextfieldHeightAnchor?.isActive = false
        emailtextfieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo:  inputContainerView.heightAnchor, multiplier:  loginRegisterSegmentedcontrol.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailtextfieldHeightAnchor?.isActive = true
        
        //change height passwordtextfield
        passwordtextfieldHeightAnchor?.isActive = false
        passwordtextfieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo:  inputContainerView.heightAnchor, multiplier:  loginRegisterSegmentedcontrol.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordtextfieldHeightAnchor?.isActive = true
    }
    
    lazy var profileImageView: UIImageView = {
        let imgProFile = UIImageView()
        imgProFile.image = UIImage(named: "Logo")
        imgProFile.translatesAutoresizingMaskIntoConstraints = false
        imgProFile.contentMode = .scaleAspectFill
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView))
        imgProFile.addGestureRecognizer(tapGesture)
        imgProFile.isUserInteractionEnabled = true
        return imgProFile
    }()
    
    let nameTextField: UITextField = {
       let tfName = UITextField()
        tfName.placeholder = "Name"
        tfName.translatesAutoresizingMaskIntoConstraints = false
        return tfName
    }()
    
    let emailTextField: UITextField = {
        let tfEmail = UITextField()
        tfEmail.placeholder = "Email"
        tfEmail.translatesAutoresizingMaskIntoConstraints = false
        return tfEmail
    }()
    
    let passwordTextField: UITextField = {
        let tfPassword = UITextField()
        tfPassword.placeholder = "Password"
        tfPassword.isSecureTextEntry = true
        tfPassword.translatesAutoresizingMaskIntoConstraints = false
        return tfPassword
    }()
    
    let nameSeparatorView: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor(r:220, g:220, b:220)
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    let emailSeparatorView: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor(r:220, g:220, b:220)
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
    
        view.addSubview(inputContainerView)
        view.addSubview(registerButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedcontrol)
        
        setupInputsContainerView()
        setupRegisterButton()
        setupImageProfile()
        setupLoginRegisterSegmentedControl()
    
    }
    
    func setupLoginRegisterSegmentedControl(){
        loginRegisterSegmentedcontrol.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedcontrol.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor , constant: -12).isActive = true
        loginRegisterSegmentedcontrol.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, multiplier:0.5).isActive = true
        loginRegisterSegmentedcontrol.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupImageProfile(){
        // x, y, width, height contraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedcontrol.topAnchor , constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupTextField(){
        //name textfield
        nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nametextfieldHeightAnchor  =  nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nametextfieldHeightAnchor?.isActive = true
        
        //separator name
        nameSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //emailtextfield
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameSeparatorView.topAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailtextfieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailtextfieldHeightAnchor?.isActive = true
        
        //separator email
        emailSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //password textfield
        passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.topAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordtextfieldHeightAnchor =  passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordtextfieldHeightAnchor?.isActive = true
        	
    }
    
    func setupInputsContainerView(){
        // x, y, width, height contraints
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerViewHeightAnchor?.isActive = true
        
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(nameSeparatorView)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailSeparatorView)
        inputContainerView.addSubview(passwordTextField)
        
        setupTextField()
    }
    
    func setupRegisterButton(){
        // x, y, width, height contraints
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo:inputContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
}

extension UIColor{
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
