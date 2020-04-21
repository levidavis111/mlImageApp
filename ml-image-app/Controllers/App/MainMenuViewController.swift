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
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stars")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var hairButton: UIButton = {
        let button = UIButton()
        button.setTitle("Hair", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.isSpringLoaded = true
        button.showsTouchWhenHighlighted = true
        button.layer.cornerRadius =  10
        button.addTarget(self, action: #selector(hairButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var artFilterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Art", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.isSpringLoaded = true
        button.showsTouchWhenHighlighted = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(artFilterButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var petButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pet", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.isSpringLoaded = true
        button.showsTouchWhenHighlighted = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(petButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var objectDetectButton: UIButton = {
        let button = UIButton()
        button.setTitle("Object ID", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.isSpringLoaded = true
        button.showsTouchWhenHighlighted = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(objectDetectButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    //    MARK: - Lifecyle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        constrainSubviews()
        setupNavBar()
    }
    
    //    MARK: - Obj-C Functions
    
    @objc private func hairButtonPressed() {
        activityIndicator.startAnimating()
        let hairColorVC = HairColorViewController()
        navigationController?.pushViewController(hairColorVC, animated: true)
        activityIndicator.stopAnimating()
    }
    
    @objc private func artFilterButtonPressed() {
        activityIndicator.startAnimating()
        let styleVC = StyleTransferViewController()
        navigationController?.pushViewController(styleVC, animated: true)
        activityIndicator.stopAnimating()
    }
    
    @objc private func petButtonPressed() {
        activityIndicator.startAnimating()
        let petVC = PetStickerViewController()
        navigationController?.pushViewController(petVC, animated: true)
        activityIndicator.stopAnimating()
    }
    
    @objc private func objectDetectButtonPressed() {
        activityIndicator.startAnimating()
        let objectVC = ObjectDetectorViewController()
        navigationController?.pushViewController(objectVC, animated: true)
        activityIndicator.stopAnimating()
    }
    
    @objc private func logout() {
        activityIndicator.startAnimating()
        FirebaseAuthService.manager.logoutUser()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window else {return}
        window.rootViewController = LoginViewController()
        window.makeKeyAndVisible()
        activityIndicator.stopAnimating()
    }
    
    //    MARK: - Private Functions
    
    private func setupNavBar() {
        let rightButton = UIBarButtonItem(title: "logout", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.title = "Select an Effect"
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    //    MARK: - Setup UI
    
    private func constrainSubviews() {
        setupBackgroundImageView()
        setupStackView()
        setupActivityIndicator()
    }
    
    private func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [hairButton, artFilterButton, petButton, objectDetectButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        backgroundImageView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        [stackView.centerXAnchor.constraint(equalTo: backgroundImageView.safeAreaLayoutGuide.centerXAnchor),
         stackView.centerYAnchor.constraint(equalTo: backgroundImageView.safeAreaLayoutGuide.centerYAnchor),
         stackView.heightAnchor.constraint(equalToConstant: 230),
         stackView.widthAnchor.constraint(equalToConstant: 80)].forEach{$0.isActive = true}
    }
    
    private func setupBackgroundImageView() {
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        [backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         backgroundImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         backgroundImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         backgroundImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)].forEach{$0.isActive = true}
        
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        [activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
         activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)].forEach {$0.isActive = true}
        
    }
    
}
