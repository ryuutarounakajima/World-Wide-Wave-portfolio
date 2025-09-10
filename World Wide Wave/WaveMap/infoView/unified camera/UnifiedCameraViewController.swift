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
    
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutPut: AVCaptureMovieFileOutput?
    
    var mode: captureMode = .photo {
        didSet {switchCamera(mode)}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSession()
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
    }
    
    
}

extension UnifiedCameraViewController {
    
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        
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
    
        DispatchQueue.main.async { [self] in
            previewLayer?.removeFromSuperlayer()
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.frame = view.bounds
            previewLayer?.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer!)
        }
       
        
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    private func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
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
