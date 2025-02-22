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
        default:
            return false
        }
    }
}

struct videoPreviewView: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    @Binding var videoURL: URL?
    
    class Coordinator: NSObject, AVCaptureFileOutputRecordingDelegate {
        
        var parent: videoPreviewView
        
        init(parent: videoPreviewView) {
            self.parent = parent
        }
        
        func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            
            if error == nil {
                
                DispatchQueue.main.async {
                    self.parent.videoURL = outputFileURL
                }
                print("Finished recording to \(outputFileURL)")
            }
         
            
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = VideoPreViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
}
class VideoPreViewController: UIViewController {
    
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    var delegate : AVCaptureFileOutputRecordingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoSession()
        setupPreViewLayer()
       
        
    }
    
    func setupVideoSession() {
        
        guard let device = AVCaptureDevice.default(for: .video),
                let input = try? AVCaptureDeviceInput(device: device) else {
            print("faled to create input")
            return }
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio), let audioInput = try? AVCaptureDeviceInput(device: audioDevice)
         else {
             print("failed to create audio input")
             return
         }
        
        session.beginConfiguration()
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if  session.canAddInput(audioInput){
            session.addInput(audioInput)        }
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func setupPreViewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
    }
    
    func startRecording() {
        let outputFilePath = FileManager.default.temporaryDirectory.appendingPathComponent("output.mp4")
        videoOutput.startRecording(to: outputFilePath, recordingDelegate: delegate!)
    }
    
    func stopRecording() {
        videoOutput.stopRecording()
    }
}
