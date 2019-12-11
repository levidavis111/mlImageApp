//
//  MainMenuViewController.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/10/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    
//    lazy var stackView: UIStackView = {
//        let stackView = UIStackView()
//
//        return stackView
//    }()
    
    lazy var aButton: UIButton = {
        let button = UIButton()
        button.setTitle("A Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    lazy var bButton: UIButton = {
        let button = UIButton()
        button.setTitle("B Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    lazy var cButton: UIButton = {
        let button = UIButton()
        button.setTitle("C Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    lazy var dButton: UIButton = {
        let button = UIButton()
        button.setTitle("D Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .blue
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupStackView()
    }
    
    
    
    
    
//    MARK: - Setup UI
    
//    private func addSubviews() {
//
//    }
    
    private func constrainSubviews() {
        setupStackView()

    }
    
    private func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [aButton, bButton, cButton, dButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        [stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
         stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
         stackView.heightAnchor.constraint(equalToConstant: 230),
         stackView.widthAnchor.constraint(equalToConstant: 80)].forEach{$0.isActive = true}
    }

}

/**
 private func setupLoginStackView() {
     let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField,loginButton])
     stackView.axis = .vertical
     stackView.spacing = 15
     stackView.distribution = .fillEqually
     self.view.addSubview(stackView)
     
     stackView.translatesAutoresizingMaskIntoConstraints = false
     NSLayoutConstraint.activate([
         stackView.bottomAnchor.constraint(equalTo: createAccountButton.topAnchor, constant: -50),
         stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
         stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
         stackView.heightAnchor.constraint(equalToConstant: 130)])
 }
 */
