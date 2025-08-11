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
    
    var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        if let session = captureSession {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds
            if let layer = previewLayer {
                view.layer.addSublayer(layer)
            }
        }
    }
    
       override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       previewLayer?.frame = view.bounds
    }
}

struct VideoPreviewView: UIViewControllerRepresentable {
    let captureSession: AVCaptureSession
    
    func makeUIViewController(context: Context) -> VideoPreviewViewController {
        let controller = VideoPreviewViewController()
        controller.captureSession = captureSession
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

/*class VideoPreviewViewController: UIViewController, AVCaptureFileOutputRecordingDelegate{
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        
    }
    
    
}
*/
