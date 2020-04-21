//
//  PetStickerViewController.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/14/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import UIKit
import Fritz
import FritzVisionPetSegmentationModelAccurate

class PetStickerViewController: UIViewController {

    private lazy var visionModel = FritzVisionPetSegmentationModelAccurate()
    
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var maskView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var backGroundView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addsubViews()
        openPhotoLibrary()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {[weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activityIndicator.stopAnimating()
    }
    
    private func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true)
        }
    }
    
    private func createSticker(_ uiImage: UIImage) {
        
        /// Scores output from model greater than this value will be set as 1.
        /// Lowering this value will make the mask more intense for lower confidence values.
        var clippingScoresAbove: Double { return 0.6 }
        
        /// Values lower than this value will not appear in the mask.
        var zeroingScoresBelow: Double { return 0.4 }
        
        let fritzImage = FritzVisionImage(image: uiImage)
        guard let result = try? visionModel.predict(fritzImage), let mask = result.buildSingleClassMask(forClass: FritzVisionPetClass.pet, clippingScoresAbove: clippingScoresAbove, zeroingScoresBelow: zeroingScoresBelow) else {return}
        
        let petSticker = fritzImage.masked(with: mask)
        
        DispatchQueue.main.async {
            self.imageView.image = petSticker
        }
    }
    
    private func addsubViews() {
        view.addSubview(backGroundView)
        view.addSubview(imageView)
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        imageView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        [activityIndicator.centerXAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.centerXAnchor),
         activityIndicator.centerYAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.centerYAnchor)].forEach {$0.isActive = true}
    }
    
}

extension PetStickerViewController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        self.dismiss(animated: true) {
            self.createSticker(image)
        }
    }
}
