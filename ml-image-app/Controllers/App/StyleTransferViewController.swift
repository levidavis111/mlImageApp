//
//  StyleTransferViewController.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/14/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import UIKit
import Photos
import Fritz

class StyleTransferViewController: UIViewController {
    
    lazy var styleModel = PaintingStyleModel.Style.starryNight.build()
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        return session
    }()
    
    
    lazy var previewView: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupCaptureSession()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        previewView.frame = view.bounds
    }
    
    private func addSubviews() {
        view.addSubview(previewView)
        
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
        self.captureSession.addOutput(videoOutput)
        self.captureSession.startRunning()
    }
    
    
    
}

extension StyleTransferViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let fritzImage = FritzVisionImage(sampleBuffer: sampleBuffer, connection: connection)
        guard let stylizedImage = try? styleModel.predict(fritzImage) else { return }
        let styled = UIImage(pixelBuffer: stylizedImage)
        DispatchQueue.main.async {
            self.previewView.image = styled
        }
        
    }
    
}

