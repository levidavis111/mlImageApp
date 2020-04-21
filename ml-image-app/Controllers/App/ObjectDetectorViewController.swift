//
//  ObjectDetectorViewController.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/14/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation
import Accelerate
import Fritz
import FritzVisionObjectModelFast

class ObjectDetectorViewController: UIViewController {
    
    private lazy var visionModel = FritzVisionObjectModelFast()
    
    private lazy var cameraView: UIView = {
        let cameraView = UIView()
        
        return cameraView
    }()
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: backCamera) else {return session}
        session.addInput(input)
        return session
    }()
    
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    let numBoxes = 100
    var boundingBoxes = [BoundingBoxOutline]()
//    let multiClass = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        constrainSubviews()
        configureCaptureSession()
        setupBoxes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cameraLayer.frame = cameraView.layer.bounds
    }
    
    override func viewDidLayoutSubviews() {
        cameraLayer.frame = cameraView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.captureSession.stopRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activityIndicator.stopAnimating()
    }
    
    
    private func addSubviews() {
        view.addSubview(cameraView)
        cameraView.layer.addSublayer(cameraLayer)
    }
    
    
    private func constrainSubviews() {
        constrainCameraView()
        setupActivityIndicator()
    }
    
    private func constrainCameraView() {
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        [cameraView.topAnchor.constraint(equalTo: view.topAnchor),
         cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor)].forEach{$0.isActive = true}
    }
    
    private func setupActivityIndicator() {
        cameraView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        [activityIndicator.centerXAnchor.constraint(equalTo: cameraView.safeAreaLayoutGuide.centerXAnchor),
         activityIndicator.centerYAnchor.constraint(equalTo: cameraView.safeAreaLayoutGuide.centerYAnchor)].forEach {$0.isActive = true}
        
    }
    
    private func configureCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        captureSession.addOutput(videoOutput)
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        DispatchQueue.main.async {[weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func setupBoxes() {
        for _ in 0..<numBoxes {
            let box = BoundingBoxOutline()
            box.addToLayer(cameraView.layer)
            boundingBoxes.append(box)
        }
    }
    
    private func drawBoxes(predictions: [FritzVisionObject]) {
        
        for (index, prediction) in predictions.enumerated() {
            let textLabel = String(format: "%.2f - %@", prediction.confidence, prediction.label)
            
            let height = Double(cameraView.frame.height)
            let width = Double(cameraView.frame.width)
            let yOffset = (height - width) / 2
            
            let box = prediction.boundingBox
            let rect = box.toCGRect(imgHeight: width, imgWidth: width, xOffset: 0.0, yOffset: yOffset)
            boundingBoxes[index].show(frame: rect, label: textLabel, color: .red, textColor: .black)
        }
        
        for index in predictions.count..<self.numBoxes {
            boundingBoxes[index].hide()
        }
        
    }
    
}


extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}


extension ObjectDetectorViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let options = FritzVisionObjectModelOptions()
        options.imageCropAndScaleOption = .centerCrop
        options.threshold = 0.5
        
        let image = FritzVisionImage(buffer: sampleBuffer)
        image.metadata = FritzVisionImageMetadata()
        image.metadata?.orientation = FritzImageOrientation(from: connection)
        
        visionModel.predict(image, options: options) { objects, error in
            if let objects = objects, objects.count > 0 {
                
                DispatchQueue.main.async {[weak self] in
                    self?.drawBoxes(predictions: objects)
                }
            }
        }
    }
    
}

