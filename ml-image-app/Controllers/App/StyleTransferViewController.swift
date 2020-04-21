//
//  StyleTransferViewController.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/14/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import UIKit
import AVFoundation
//import photos to select on an image
//import Photos
import Fritz
import FritzVisionStyleModelPaintings

class StyleTransferViewController: UIViewController {
    
    private var counter = 0
    private lazy var selectedStyle = PaintingStyleModel.Style.starryNight.build()
    private lazy var styleModel = PaintingStyleModel.Style.starryNight.build()
    
    private lazy var styleModel1 = PaintingStyleModel.Style.bicentennialPrint.build()
    private lazy var styleModel2 = PaintingStyleModel.Style.femmes.build()
    private lazy var styleModel3 = PaintingStyleModel.Style.poppyField.build()
    private lazy var styleModel4 = PaintingStyleModel.Style.ritmoPlastico.build()
    
    private lazy var styleChoices = [styleModel, styleModel1, styleModel2, styleModel4, styleModel4]
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        return session
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        return tap
    }()
    
    private lazy var previewView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var tapLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Tap Screen To Change"
        
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupCaptureSession()
        setConstraints()
        addTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {[weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewView.frame = view.bounds
    }
    
    //    MARK: - Obj-C Functions
    
    @objc private func screenTapped() {
        if counter < styleChoices.count - 1 {
            counter += 1
            selectedStyle = styleChoices[counter]
        } else {
            counter = 0
            selectedStyle = styleChoices[counter]
        }
    }
    
    private func addSubviews() {
        view.addSubview(previewView)
        view.addSubview(tapLabel)
    }
    
    private func setConstraints() {
        constrainTapLabel()
    }
    
    private func constrainTapLabel() {
        tapLabel.translatesAutoresizingMaskIntoConstraints = false
        [tapLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
         tapLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)].forEach{$0.isActive = true}
    }
    
    private func addTapGesture() {
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupCaptureSession() {
        guard
            let backCamera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else { return }
        captureSession.addInput(input)
        
        // The style transfer takes a 640x480 image as input and outputs an image of the same size.
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as UInt32]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        captureSession.addOutput(videoOutput)

    }
    
    
    
}

extension StyleTransferViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let fritzImage = FritzVisionImage(sampleBuffer: sampleBuffer, connection: connection)
        guard let stylizedImage = try? selectedStyle.predict(fritzImage) else { return }
        let styled = UIImage(pixelBuffer: stylizedImage)
        DispatchQueue.main.async {[weak self] in
            self?.previewView.image = styled
        }
        
    }
    
}

