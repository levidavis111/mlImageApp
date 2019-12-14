//
//  PetStickerViewController.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/14/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import UIKit
import AVFoundation
import Fritz
import FritzVisionPetSegmentationModelAccurate

class PetStickerViewController: UIViewController {
    
    /// Scores output from model greater than this value will be set as 1.
     /// Lowering this value will make the mask more intense for lower confidence values.
     var clippingScoresAbove: Double { return 0.6 }
     
     /// Values lower than this value will not appear in the mask.
     var zeroingScoresBelow: Double { return 0.4 }

     private lazy var visionModel = FritzVisionPetSegmentationModelAccurate()
    
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var maskView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var backGroundView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()
    
    let context = CIContext()

    override func viewDidLoad() {
        super.viewDidLoad()
        addsubViews()
        openPhotoLibrary()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    }
    
}

extension PetStickerViewController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        self.dismiss(animated: true) {
            self.createSticker(image)
        }
        
//        self.imageView.image = image
    }
}
