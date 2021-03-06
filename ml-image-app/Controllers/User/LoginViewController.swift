//
//  LoginViewController.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/9/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = false
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    
    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "ML Image App"
        label.font = UIFont(name: "Verdana-Bold", size: 60)
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
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(tryLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ",
                                                        attributes: [
                                                            NSAttributedString.Key.font: UIFont(name: "Verdana", size: 14)!,
                                                            NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)])
        attributedTitle.append(NSAttributedString(string: "Sign Up",
                                                  attributes: [NSAttributedString.Key.font: UIFont(name: "Verdana-Bold", size: 14)!,
                                                               NSAttributedString.Key.foregroundColor:  UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(showSignUp), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        constrainSubviews()
        dismissKeyboardWithTap()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardSelectorTriggered(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        constrainSubviews()
        self.scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height + 500 )
    }
    
//    MARK: - Obj-C Functions
    
    @objc private func validateFields() {
        guard emailTextField.hasText, passwordTextField.hasText else {loginButton.backgroundColor = .lightGray; loginButton.isEnabled = false; return}
        loginButton.backgroundColor = .cyan
        loginButton.isEnabled = true
    }
    
    @objc private func showSignUp() {
        let signupVC = CreateAccountViewController()
        signupVC.modalPresentationStyle = .formSheet
        present(signupVC, animated: true)
    }
    
    @objc private func tryLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {addAlert(title: "Error", message: "Please fill out all fields"); return}
        guard email.isValidEmail else {addAlert(title: "Error", message: "Please enter a valid email"); return}
        guard password.isValidPassword else {addAlert(title: "Error", message: "Please enter a valid password"); return}
        
        FirebaseAuthService.manager.loginUser(email: email, password: password) { (result) in
            self.handleLoginResponse(with: result)
        }
        
    }
    
    @objc private func keyboardSelectorTriggered(sender: Notification) {
        moveViewsToAccomadateKeyboard(with: CGRect(x: 0, y: 0, width: 414, height: 346), and: 0.25)
    }
    
    @objc private func dismissKeyboard() {
        scrollView.endEditing(true)
    }
    
//    MARK: - Private Functions
    
    private func addAlert(title: String? = nil, message: String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okayAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func handleLoginResponse(with result: Result <(), Error>) {
        switch result {
        case .failure(let error):
            print(error)
            addAlert(title: "Error", message: "Could not log in. No User Found")
        case .success(()):
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window else {return}
            
            let mainVC = MainMenuViewController()
            let navController = UINavigationController(rootViewController: mainVC)
            window.rootViewController = navController
            window.makeKeyAndVisible()
        }
    }
    
    private func moveViewsToAccomadateKeyboard(with keyboardRect: CGRect, and duration: Double) {
        guard keyboardRect != CGRect.zero else {
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
            return
        }
        
        let hiddenAreaRect = keyboardRect.intersection(scrollView.bounds)
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: hiddenAreaRect.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        
        var lgb = loginButton.frame
        lgb = scrollView.convert(lgb, from: loginButton.superview)
        lgb = lgb.insetBy(dx: 0.0, dy: -20)
        scrollView.scrollRectToVisible(lgb, animated: true)
        
    }
    
    private func dismissKeyboardWithTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tap)
    }
    
//    MARK: - Setup UI
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(logoLabel)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(createAccountButton)
    }
    
    private func constrainSubviews() {
        setScrollViewConstraints()
        setLogoConstraints()
        setupEmailTextField()
        setupPasswordTextField()
        setupLoginButton()
        setupCreateAccountButton()
    }
    
    private func setScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        [scrollView.topAnchor.constraint(equalTo: view.topAnchor),
         scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)].forEach {$0.isActive = true}
    }
    
    private func setLogoConstraints() {
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        [logoLabel.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor, constant: 60),
         logoLabel.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
         logoLabel.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -16)].forEach{$0.isActive = true}
    }
    
    private func setupEmailTextField() {
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        [emailTextField.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
         emailTextField.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
         emailTextField.heightAnchor.constraint(equalToConstant: 50),
         emailTextField.widthAnchor.constraint(equalToConstant: 300)].forEach{$0.isActive = true}
    }
    
    private func setupPasswordTextField() {
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        [passwordTextField.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
         passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
         passwordTextField.heightAnchor.constraint(equalToConstant: 50),
         passwordTextField.widthAnchor.constraint(equalToConstant: 300)].forEach{$0.isActive = true}
    }
    
    private func setupLoginButton() {
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        [loginButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
         loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
         loginButton.heightAnchor.constraint(equalToConstant: 50),
         loginButton.widthAnchor.constraint(equalToConstant: 300)].forEach{$0.isActive = true}
    }
    
    private func setupCreateAccountButton() {
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        [createAccountButton.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor),
         createAccountButton.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor),
         createAccountButton.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
         createAccountButton.heightAnchor.constraint(equalToConstant: 50)].forEach{$0.isActive = true}
    }
    
}
