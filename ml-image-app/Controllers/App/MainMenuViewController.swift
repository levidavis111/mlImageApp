//
//  MainMenuViewController.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/10/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    
//    MARK: - UI Elements
    
    lazy var aButton: UIButton = {
        let button = UIButton()
        button.setTitle("A Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .blue
        button.isSpringLoaded = true
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(aButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var bButton: UIButton = {
        let button = UIButton()
        button.setTitle("B Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .blue
        button.isSpringLoaded = true
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(bButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var cButton: UIButton = {
        let button = UIButton()
        button.setTitle("C Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .blue
        button.isSpringLoaded = true
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(cButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var dButton: UIButton = {
        let button = UIButton()
        button.setTitle("D Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .blue
        button.isSpringLoaded = true
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(dButtonPressed), for: .touchUpInside)
        return button
    }()
    
//    MARK: - Lifecyle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupStackView()
        setupNavBar()
    }
    
//    MARK: - Obj-C Functions
    
    @objc private func aButtonPressed() {
        let hairColorVC = HairColorViewController()
        navigationController?.pushViewController(hairColorVC, animated: true)
    }
    
    @objc private func bButtonPressed() {
    print("b")
    }
    
    @objc private func cButtonPressed() {
    print("c")
    }
    
    @objc private func dButtonPressed() {
    print("d")
    }
    
    @objc private func logout() {
        FirebaseAuthService.manager.logoutUser()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window else {return}
        window.rootViewController = LoginViewController()
        window.makeKeyAndVisible()
    }
    
//    MARK: - Private Functions
    
    private func setupNavBar() {
        let rightButton = UIBarButtonItem(title: "logout", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
//    MARK: - Setup UI
    
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
