//
//  CameraManager.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/12/30.
//

import SwiftUI
import AVFoundation

actor CameraManager {
    func requestCameraAccess() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
}

actor PhotoCaptureManager {
    private(set) var captureImage: UIImage? = nil
    
    func savePhoto(_ image: UIImage)  {
        self.captureImage = image
    }
}

struct CameraPreviewView: UIViewControllerRepresentable {
    
    @Binding var captureImage: UIImage?
    @Binding var isCameraPresented: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = CameraPreviewController()
    
        
        controller.onPhotoCaptured = { image in
            DispatchQueue.main.async {
                self.captureImage = image
            }
        }
        
        controller.onCameraDismissed = {
            DispatchQueue.main.async {
                self.isCameraPresented = false
            }
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    /*
     func dismantleUIViewController(_ uiViewController: CameraPreviewController, context: Context) {
        DispatchQueue.global(qos: .background).async {
            if uiViewController.session.isRunning {
                uiViewController.session.stopRunning()
                print("seesion stopped")
            }
            
        }
    }
     */
}

class CameraPreviewController: UIViewController, AVCapturePhotoCaptureDelegate {
    public let session = AVCaptureSession()
    private let videoPreviewLayer = AVCaptureVideoPreviewLayer()
    private let photoOutPut = AVCapturePhotoOutput()
    private var photoCaptureManager: PhotoCaptureManager?
    var onPhotoCaptured: ((UIImage) -> Void)?
    var onCameraDismissed: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraSession()
        setupPreviewLayer()
        setuoCaputreButton()
    }
    
    private func setupCameraSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("failed to load camera")
            return
        }
        
        session.addInput(input)
        
        if session.canAddOutput(photoOutPut){
            session.addOutput(photoOutPut)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    private func setupPreviewLayer() {
        videoPreviewLayer.session = session
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        view.layer.addSublayer(videoPreviewLayer)
    }
    
    private func setuoCaputreButton() {
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("", for: .normal)
        captureButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        captureButton.frame = CGRect(x: view.frame.width / 2 - 25, y: view.frame.height - 80, width: 50, height: 50)
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
        
        
    }
    
    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutPut.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let photoData = photo.fileDataRepresentation(),
              let image = UIImage(data: photoData) else {
            print("Failed to convert photo")
            return }
        onPhotoCaptured?(image)
        
        onCameraDismissed?()
    }
}

