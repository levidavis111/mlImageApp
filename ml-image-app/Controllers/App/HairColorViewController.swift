//
//  HairColorViewController.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/10/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import UIKit
import AVFoundation
import Fritz
import ColorSlider

class HairColorViewController: UIViewController, HairPredictor {
    
    lazy var visionModel = FritzVisionHairSegmentationModelFast()
    var colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
    
    lazy var cameraView: UIImageView = {
        let cameraView = UIImageView(frame: view.bounds)
        cameraView.contentMode = .scaleAspectFill
        
        return cameraView
    }()
    
    private lazy var captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.fritzdemo.imagesegmentation.session")
    private let captureQueue = DispatchQueue(label: "com.fritzdemo.imagesegmentation.capture",
                                             qos: DispatchQoS.userInitiated)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        addColorSlider()
        setupCamera()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.bringSubviewToFront(colorSlider)
    }
    
    private func addSubviews() {
        view.addSubview(cameraView)
    }
    
    private func setupCamera() {
        // Setup camera
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: device)
            else { return }
        
        let output = AVCaptureVideoDataOutput()
        
        // Configure pixelBuffer format for use in model
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as UInt32]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: captureQueue)
        
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.addInput(input)
            self.captureSession.addOutput(output)
            self.captureSession.commitConfiguration()
            self.captureSession.sessionPreset = .photo
            
            // Front camera images are mirrored.
            output.connection(with: .video)?.isVideoMirrored = true
        }
    }
}

extension HairColorViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    /// Scores output from model greater than this value will be set as 1.
    /// Lowering this value will make the mask more intense for lower confidence values.
    var clippingScoresAbove: Double { return 0.7 }
    
    /// Values lower than this value will not appear in the mask.
    var zeroingScoresBelow: Double { return 0.3 }
    
    /// Controls the opacity the mask is applied to the base image.
    var opacity: CGFloat { return 0.7 }
    
    /// The method used to blend the hair mask with the underlying image.
    /// Soft light produces the best results in our tests, but check out
    /// .hue and .color for different effects.
    var blendKernel: CIBlendKernel { return .softLight }
    
    /// Color of the mask.
    var maskColor: UIColor { return colorSlider.color }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let image = FritzVisionImage(sampleBuffer: sampleBuffer, connection: connection)
        
        guard let result = try? visionModel.predict(image),
            let mask = result.buildSingleClassMask(
                forClass: FritzVisionHairClass.hair,
                clippingScoresAbove: clippingScoresAbove,
                zeroingScoresBelow: zeroingScoresBelow,
                resize: false,
                color: maskColor)
            else { return }
        
        let blended = image.blend(
            withMask: mask,
            blendKernel: blendKernel,
            opacity: opacity
        )
        
        DispatchQueue.main.async {
            self.cameraView.image = blended
        }
    }
}
