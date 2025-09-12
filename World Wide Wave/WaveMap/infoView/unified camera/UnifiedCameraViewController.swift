//
//  UnifiedCameraViewController.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/09/09.
//

import Foundation
import AVFoundation
import SwiftUI

enum captureMode {
    case photo
    case video
}

class UnifiedCameraViewController : UIViewController {
    //setup
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    //.photo .video
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutPut: AVCaptureMovieFileOutput?
    var mode: captureMode = .photo {
        didSet {switchCamera(mode)}
    }
    
    //rotation angle
    private var currentDeviceAngle: AVCaptureDevice?
    private var previewAngleObserver: NSKeyValueObservation?
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    
   //button
    //private  var captureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSession()
       // setupCaptureButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switchCamera(mode)
        startSession()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        
       // upDateButtonPosition()
        //view.bringSubviewToFront(captureButton)
    }
    
    
}

extension UnifiedCameraViewController {
    
    /*   //MARK: - button
    private func setupCaptureButton() {
        
        captureButton = UIButton(type: .system)
        captureButton.setTitle("", for: .normal)
        captureButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        
        let buttonSize: CGFloat = 50
        captureButton.layer.cornerRadius = buttonSize / 2
        captureButton.clipsToBounds = true
       
        let xPosition = (view.bounds.width - buttonSize) / 2
        let yPosition = (view.bounds.height - buttonSize) - 50
     
     captureButton.frame = CGRect(x: xPosition, y: yPosition, width: buttonSize, height: buttonSize)
        view.addSubview(captureButton)
     
     
     //captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        upDateButtonPosition()
        //view.bringSubviewToFront(captureButton)
    }
    
    private func upDateButtonPosition() {
        
        let buttonSize: CGFloat = 50
        let xPosition = (view.bounds.width - buttonSize) / 2
        let yPosition = (view.bounds.height - buttonSize) - 50
        
        captureButton.frame = CGRect(x: xPosition, y: yPosition, width: buttonSize, height: buttonSize)
    }
    */
    //MARK: - setup
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
       
        self.currentDeviceAngle = device
        
        let photoOut = AVCapturePhotoOutput()
        if session.canAddOutput(photoOut) {
            session.addOutput(photoOut)
            self.photoOutput = photoOut
        }
        
        let videoOut = AVCaptureMovieFileOutput()
        if session.canAddOutput(videoOut) {
            session.addOutput(videoOut)
            self.videoOutPut = videoOut
            session.removeOutput(videoOut)
        }
        
        session.commitConfiguration()
    
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            previewLayer?.removeFromSuperlayer()
            let layer = AVCaptureVideoPreviewLayer(session: self.session)
            layer.frame = self.view.bounds
            layer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(layer)
            self.previewLayer = layer
            
           // self.view.bringSubviewToFront(self.captureButton)
        }
       
        
    }
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in guard let self = self else { return }
            
            if !self.session.isRunning {
                self.session.startRunning()
                
                DispatchQueue.main.async {
                    self.setupRotationCoordinator()
                }
               
            }
        }
    }
    private func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    func switchCamera(_ mode: captureMode) {
        session.beginConfiguration()
        
        if mode == .photo {
            if let videoOut = videoOutPut, session.outputs.contains(videoOut) {
                session.removeOutput(videoOut)
            }
            if let photoOutput = photoOutput, !session.outputs.contains(photoOutput) {
                session.addOutput(photoOutput)
            }
            print("photo mode open")
        } else {
            if let photoOutput = photoOutput, session.outputs.contains(photoOutput) {
                session.removeOutput(photoOutput)
            }
            if let videoOutPut = videoOutPut, !session.outputs.contains(videoOutPut) {
                session.addOutput(videoOutPut)
            }
            print("video mode open")
        }
        
        session.commitConfiguration()
            //updateRoationCoordinator()
    }
    
    //MARK: - rotation coordinate
    private func setupRotationCoordinator() {
        
        guard let device =
                currentDeviceAngle, let previewLayer = previewLayer else { return }
        
        let coordinator =
        AVCaptureDevice.RotationCoordinator(device: device, previewLayer: previewLayer)
        
        self.rotationCoordinator = coordinator
        
        previewAngleObserver = coordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.initial, .new]) { [weak self] coordinator, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let connection = self.previewLayer?.connection {
                    let previewAngle = coordinator.videoRotationAngleForHorizonLevelPreview
                    if connection.isVideoRotationAngleSupported(previewAngle) {
                        connection.videoRotationAngle = previewAngle
                    }
                }
                
                self.updateRoationCoordinator()
            }
            
        }
       
    }
    private func updateRoationCoordinator() {
        guard let coordinator = rotationCoordinator else { return }
        let captureAngle = coordinator.videoRotationAngleForHorizonLevelCapture
        
        if let connection = photoOutput?.connection(with: .video),
           connection.isVideoRotationAngleSupported(captureAngle) {
            connection.videoRotationAngle = captureAngle
        }
        
        if let connection = videoOutPut?.connection(with: .video), connection.isVideoRotationAngleSupported(captureAngle) {
            connection.videoRotationAngle = captureAngle
        }
    }
    
    
  
    
}

struct UnifiedCameraView: UIViewControllerRepresentable {
   
   @Binding var mode: captureMode
   
   func makeUIViewController(context: Context) -> UnifiedCameraViewController {
       
       let vc = UnifiedCameraViewController()
       vc.mode = mode
       return vc
   }
   
   func updateUIViewController(_ uiViewController: UnifiedCameraViewController, context: Context) {
       
       if uiViewController.mode != mode {
           uiViewController.mode = mode
       }
   }
}
