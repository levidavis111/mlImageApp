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
    
    lazy var visionModel = FritzVisionObjectModelFast()
    var lastExecution = Date()
    lazy var screenHeight = Double(view.frame.height)
    lazy var screenWidth = Double(view.frame.width)
    
    
    lazy var cameraView: UIView = {
        let cameraView = UIView()
        
        return cameraView
    }()
    
    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: backCamera) else {return session}
        session.addInput(input)
        return session
    }()
    
    lazy var cameraLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    let numBoxes = 100
    var boundingBoxes = [BoundingBoxOutline]()
    let multiClass = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        constrainSubviews()
        configureCaptureSession()
        setupBoxes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cameraLayer.frame = cameraView.layer.bounds
    }
    
    override func viewDidLayoutSubviews() {
        self.cameraLayer.frame = self.cameraView.bounds
    }
    
    
    private func addSubviews() {
        self.view.addSubview(cameraView)
        self.cameraView.layer.addSublayer(cameraLayer)
    }
    
    
    private func constrainSubviews() {
        constrainCameraView()
    }
    
    private func constrainCameraView() {
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        [cameraView.topAnchor.constraint(equalTo: view.topAnchor),
         cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor)].forEach{$0.isActive = true}
    }
    
    private func configureCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        self.captureSession.addOutput(videoOutput)
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        self.captureSession.startRunning()
    }
    
    private func setupBoxes() {
        for _ in 0..<numBoxes {
            let box = BoundingBoxOutline()
            box.addToLayer(cameraView.layer)
            self.boundingBoxes.append(box)
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
            self.boundingBoxes[index].show(frame: rect, label: textLabel, color: .red, textColor: .black)
        }
        
        for index in predictions.count..<self.numBoxes {
            self.boundingBoxes[index].hide()
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
                
                DispatchQueue.main.async {
                    self.drawBoxes(predictions: objects)
                }
            }
        }
    }
    
}

