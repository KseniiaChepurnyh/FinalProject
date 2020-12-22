//
//  SignUpViewController.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 09.12.2020.
//

import UIKit
import SnapKit
import Firebase

class SignUpViewController: UIViewController {

    // MARK: UI Properties
    
    private let titleLabel: UILabel = {
        return UILabel().createLogo()
    }()
    
    private let emailTextField: UITextField = {
        return UITextField().createTextField(withPlacehplder: "Email", isSecureTextEntry: false)
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().createTextField(withPlacehplder: "Password", isSecureTextEntry: false)
    }()
    
    private let fullNameTextField: UITextField = {
        return UITextField().createTextField(withPlacehplder: "Full Name", isSecureTextEntry: false)
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().createInputContainerView(image: #imageLiteral(resourceName: "envelope"), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().createInputContainerView(image: #imageLiteral(resourceName: "padlock"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let phoneTextField: UITextField = {
        return UITextField().createTextField(withPlacehplder: "+79999999999", isSecureTextEntry: false)
    }()
    
    private lazy var phoneContainerView: UIView = {
        let view = UIView().createInputContainerView(image: #imageLiteral(resourceName: "padlock"), textField: phoneTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var fullNameContainerView: UIView = {
        let view = UIView().createInputContainerView(image: #imageLiteral(resourceName: "name"), textField: fullNameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton().createAuthButton(text: "Sign Up")
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton().createNavigationButton(text1: "Already have an account", text2: "Log In")
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: Functions
    
    func configureUI() {
        
        view.backgroundColor = .backgruondColor
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        let stack = UIStackView(arrangedSubviews: [fullNameContainerView, phoneContainerView, emailContainerView, passwordContainerView, signUpButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 25
        
        view.addSubview(stack)
        stack.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom).inset(40)
            make.centerX.equalTo(view)
        }
    }

    
    // MARK: - Navigation
    @objc func signUp() {
        guard let fullName = fullNameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let phone = phoneTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Failed with \(error.localizedDescription)")
            }
            
            guard let uid = result?.user.uid else { return }
            
            let values = ["email" : email, "fullname" : fullName, "phoneNumber": phone, "uid": uid] as [String : Any]
            
            Database.database().reference().child("users").child(uid).updateChildValues(values) { (error, ref) in
                print("Registered")
                let mainVC = MainViewController()
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true)
            }
        }
    }
    
    @objc func handleShowLogIn() {
        self.dismiss(animated: true, completion: nil)
    }

}
