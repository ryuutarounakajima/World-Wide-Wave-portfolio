//
//  VideoManager.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/02/16.
//

import UIKit
import SwiftUI
import AVFoundation

actor MicManager {
    func requestMicAccess() async -> Bool {
        
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch micStatus {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .audio)
        case .denied:
            print("mic access denied")
            try? await Task.sleep(nanoseconds: 5_000_000)
            
            let newStatus = AVCaptureDevice.authorizationStatus(for: .audio)
           
            if newStatus == .authorized {
                return true
            } else {
                return false
            }
        default:
            return true
        }
    }
}

class VideoPreviewViewController: UIViewController {
    
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoOutput: AVCaptureVideoDataOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupCamera()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOenrationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications( )
      
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
           
       previewLayer?.frame = view.bounds
     
    }
    
}

extension VideoPreviewViewController{
    
    private func setupCamera() {
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
           if granted {
                DispatchQueue.main.async {
                    self.configureSession()
               }
           } else {
               print("Camera access denied")
           }
        }
    }
    
    private func configureSession() {
        
        session.beginConfiguration()
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            
            print("No camera exists")
            session.commitConfiguration()
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print("camera input error: \(error)")
        }
        
        let output = AVCaptureVideoDataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            videoOutput = output
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.session.startRunning()
            DispatchQueue.main.async {
                self.updateVideoOrientation()
            }
        }
    }
    
    private func updateVideoOrientation() {
        
        guard let connection  = previewLayer?.connection else { return }
        
        let angle: CGFloat
        
        switch UIDevice.current.orientation {
        case .portrait:
            angle = 90
        case .landscapeLeft:
            angle = 0
        case .landscapeRight:
            angle = 180
        case .portraitUpsideDown:
            angle = 270
        default:
            return
        }
        
        if connection.isVideoRotationAngleSupported(angle) {
            connection.videoRotationAngle = angle
        }
    }
    @objc private func deviceOenrationDidChange() {
        updateVideoOrientation()
    }
    
    
   
}

struct VideoPreviewView: UIViewControllerRepresentable {
    let captureSession: AVCaptureSession
    
    func makeUIViewController(context: Context) -> VideoPreviewViewController {
       
        return VideoPreviewViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

/*class VideoPreviewViewController: UIViewController, AVCaptureFileOutputRecordingDelegate{
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        
    }
    
    
}
*/
