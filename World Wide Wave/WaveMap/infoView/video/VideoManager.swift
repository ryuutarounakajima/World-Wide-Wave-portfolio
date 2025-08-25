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
    private var videoDataOutoput: AVCaptureVideoDataOutput?
    private var videoFileOutput: AVCaptureFileOutput?
    private var captureButton: UIButton!
    private var isRcording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupCamera()
        setupPreviewLayer()
        setupCaptureBuuton()
        
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
       upDateButtonPosition()
     
    }
    
   
   
    
}

extension VideoPreviewViewController: AVCaptureFileOutputRecordingDelegate {
    
    
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
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutoput = videoDataOutput
        }
        
        let videoFileOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(videoFileOutput) {
            session.addOutput(videoFileOutput)
            self.videoFileOutput = videoFileOutput
        }
   
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.updateVideoOrientation()
            }
        }
    }
    
    private func setupPreviewLayer() {
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        
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
    
    private func setupCaptureBuuton() {
        
        captureButton = UIButton(type: .system)
        captureButton.setTitle("", for: .normal)
        captureButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        
        let buttonSize: CGFloat = 50
        captureButton.layer.cornerRadius = buttonSize / 2
        captureButton.clipsToBounds = true
        
        view.addSubview(captureButton)
    }
    private func captureButtonTapped() {
        guard let videoFileOutput = self.videoFileOutput else { return }
        
        if !isRcording {
            
            let outputPath = NSTemporaryDirectory() + "output.mp4"
            let fileURL = URL(fileURLWithPath: outputPath)
            
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Error removing existing file: \(error)")
            }
            
            videoFileOutput.startRecording(to: fileURL, recordingDelegate: self)
            isRcording = true
            captureButton.backgroundColor = UIColor.red
        } else {
            videoFileOutput.stopRecording()
            isRcording = false
            captureButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        }
        
        
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        
        if let error = error {
            print("Recoding error: \(error)")
        } else {
            print("Recording complete: \(outputFileURL)")
            
        }
    }

    private func upDateButtonPosition() {
        
        let buttonSize: CGFloat = 50
        let xPosition = (view.bounds.width - buttonSize) / 2
        let yPosition = (view.bounds.height - buttonSize) - 50
        
        captureButton.frame = CGRect(x: xPosition, y: yPosition, width: buttonSize, height: buttonSize)
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
