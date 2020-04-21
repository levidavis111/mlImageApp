//
//  CreateAccountViewController.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/9/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateAccountViewController: UIViewController {
    
    //    MARK: - UI Elements
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Create Account"
        label.font = UIFont(name: "Verdana-Bold", size: 28)
        label.textColor = .black
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Email"
        textField.font = UIFont(name: "Verdana", size: 14)
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.borderStyle = .bezel
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(validateFields), for: .editingChanged)
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Password"
        textField.font = UIFont(name: "Verdana", size: 14)
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.borderStyle = .bezel
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        textField.addTarget(self, action: #selector(validateFields), for: .editingChanged)
        return textField
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(trySignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    //MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHeaderLabel()
        setupCreateStackView()
    }
    
    //MARK: - Objc Functions
    
    @objc func validateFields() {
        guard emailTextField.hasText, passwordTextField.hasText else {
            createButton.backgroundColor = .lightGray
            createButton.isEnabled = false
            return
        }
        createButton.isEnabled = true
        createButton.backgroundColor = .cyan
    }
    
    @objc func trySignUp() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showAlert(title: "Error", message: "Please fill out all fields.")
            return
        }
        
        guard email.isValidEmail else {
            showAlert(title: "Error", message: "Please enter a valid email")
            return
        }
        
        guard password.isValidPassword else {
            showAlert(title: "Error", message: "Please enter a valid password. Passwords must have at least 8 characters.")
            return
        }
        
        FirebaseAuthService.manager.createNewUser(email: email.lowercased(), password: password) { [weak self] (result) in
            self?.handleCreateAccountResponse(with: result)
        }
    }
    
    //MARK: - Private Functions
    
    private func showAlert(title: String? = nil, message: String? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    private func handleCreateAccountResponse(with result: Result<User, Error>) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let user):
                FirestoreService.manager.createAppUser(user: AppUser(from: user)) { [weak self] newResult in
                    self?.handleCreatedUserInFirestore(result: newResult)
                }
            case .failure(let error):
                print(error)
                self?.showAlert(title: "Error creating user", message: "An error occured while creating new account")
            }
        }
    }
    
    private func handleCreatedUserInFirestore(result: Result<(), Error>) {
        switch result {
            
        case .failure(let error):
            print(error)
            showAlert(title: "Error", message: "Error: Could not create account")
        case .success(()):
            print("AppUser Created")
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window else {return}
            
            let mainVC = MainMenuViewController()
            let navController = UINavigationController(rootViewController: mainVC)
            window.rootViewController = navController
            window.makeKeyAndVisible()
        }
    }
    
    //MARK: - UI Setup
    
    
    private func setupHeaderLabel() {
        view.addSubview(headerLabel)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            headerLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            headerLabel.heightAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.08)])
    }
    
    
    private func setupCreateStackView() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,createButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        self.view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)])
    }
    
}
