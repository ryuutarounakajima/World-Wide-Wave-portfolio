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

struct UnifiedCameraView: UIViewControllerRepresentable {
    
    @Binding var mode: captureMode
    
    func makeUIViewController(context: Context) -> UnifiedCameraViewController {
        
        let vc = UnifiedCameraViewController()
        vc.mode = mode
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UnifiedCameraViewController, context: Context) {
        uiViewController.switchTo(mode)
    }
}
class UnifiedCameraViewController: UIViewController {

    private var photoSession: AVCaptureSession?
    private var videoSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    var mode: captureMode = .photo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCurrentSession()
    }
    
}

extension UnifiedCameraViewController {
    
    private func setupPhotoSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
    
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        photoSession = session
    }
    
    private func setupVideoSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: device) else { return }
       
        if session.canAddInput(input) {
            session.addInput(input)
            videoSession = session
        }
    }
    
    private func stopCurrentSession() {
        switch mode {
        case .photo: photoSession?.stopRunning()
        case .video: videoSession?.stopRunning()
        }
    }
    
    func switchTo(_ mode: captureMode) {
    
    stopCurrentSession()
    self.mode = mode
    
    let session = (mode == .photo) ? photoSession : videoSession
    guard let session = session else { return }
    
    previewLayer?.removeFromSuperlayer()
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer?.frame = view.bounds
    previewLayer?.videoGravity = .resizeAspectFill
    if let layer = previewLayer {
        view.layer.addSublayer(layer)
    }
    session.startRunning()
}
}
